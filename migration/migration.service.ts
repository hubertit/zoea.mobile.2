/**
 * V1 → V2 Migration Service
 * 
 * Handles the complete migration from V1 (MariaDB) to V2 (PostgreSQL)
 */

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as mysql from 'mysql2/promise';
import * as bcrypt from 'bcrypt';
import { createMediaRecordFromV1Url } from './utils/image-verifier';
import { getOrCreateCountry, getOrCreateCity } from './utils/location-mapper';
import { batchCreateMerchantProfilesForUser } from './utils/merchant-profile-mapper';
import { cleanUserData } from './utils/user-data-cleaner';

@Injectable()
export class MigrationService {
  private readonly logger = new Logger(MigrationService.name);
  private v1Connection: mysql.Connection | null = null;

  constructor(private prisma: PrismaService) {}

  /**
   * Initialize V1 database connection
   */
  async connectV1(config: {
    host: string;
    port: number;
    user: string;
    password: string;
    database: string;
  }): Promise<void> {
    this.v1Connection = await mysql.createConnection({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      database: config.database,
    });
    this.logger.log('Connected to V1 database');
  }

  /**
   * Close V1 database connection
   */
  async disconnectV1(): Promise<void> {
    if (this.v1Connection) {
      await this.v1Connection.end();
      this.v1Connection = null;
      this.logger.log('Disconnected from V1 database');
    }
  }

  /**
   * Clean age field (remove 'yes', convert to number)
   */
  cleanAge(age: string): number | null {
    if (!age || age.toLowerCase() === 'yes' || age.trim() === '') {
      return null;
    }
    const numeric = parseInt(age, 10);
    if (isNaN(numeric) || numeric < 0 || numeric > 150) {
      return null;
    }
    return numeric;
  }

  /**
   * Convert coordinates string to PostGIS geography
   */
  convertCoordinates(coords: string): { lat: number; lng: number } | null {
    if (!coords || coords.trim() === '') {
      return null;
    }
    const parts = coords.split(',').map(s => s.trim());
    if (parts.length !== 2) {
      return null;
    }
    const lat = parseFloat(parts[0]);
    const lng = parseFloat(parts[1]);
    if (isNaN(lat) || isNaN(lng)) {
      return null;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }
    return { lat, lng };
  }

  /**
   * Convert coordinates to PostGIS POINT string
   */
  toPostGIS(lat: number, lng: number): string {
    return `POINT(${lng} ${lat})`;
  }

  /**
   * Remove duplicates from array
   */
  removeDuplicates<T>(records: T[], keyFn: (record: T) => string): T[] {
    const seen = new Set<string>();
    const unique: T[] = [];
    for (const record of records) {
      const key = keyFn(record);
      if (!seen.has(key)) {
        seen.add(key);
        unique.push(record);
      }
    }
    return unique;
  }

  /**
   * Migrate countries from V1 to V2
   */
  async migrateCountries(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [rows] = await this.v1Connection.execute('SELECT * FROM countries');
    const countries = rows as any[];

    let success = 0;
    let failed = 0;

    for (const country of countries) {
      try {
        await getOrCreateCountry(country.country_id, this.prisma);
        success++;
      } catch (error) {
        this.logger.error(`Failed to migrate country ${country.country_id}:`, error);
        failed++;
      }
    }

    this.logger.log(`Migrated ${success} countries, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Migrate cities (locations) from V1 to V2
   */
  async migrateCities(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [locations] = await this.v1Connection.execute('SELECT * FROM locations');
    const locationRows = locations as any[];

    // Get all unique country_id values from venues
    const [venueCountries] = await this.v1Connection.execute(
      'SELECT DISTINCT country_id FROM venues WHERE country_id IS NOT NULL'
    );
    const countryIds = (venueCountries as any[]).map((v) => v.country_id);

    let success = 0;
    let failed = 0;

    for (const location of locationRows) {
      for (const countryId of countryIds) {
        try {
          await getOrCreateCity(location.location_id, countryId, this.prisma);
          success++;
        } catch (error) {
          this.logger.error(
            `Failed to migrate city ${location.location_id} for country ${countryId}:`,
            error
          );
          failed++;
        }
      }
    }

    this.logger.log(`Migrated ${success} city mappings, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Migrate users from V1 to V2
   */
  async migrateUsers(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    // Get all users, including those with minimal data
    const [rows] = await this.v1Connection.execute(
      'SELECT * FROM users'
    );
    const users = rows as any[];

    let success = 0;
    let failed = 0;

    for (const v1User of users) {
      try {
        // Check if user already migrated by legacy_id
        const existingByLegacy = await this.prisma.user.findUnique({
          where: { legacyId: v1User.user_id },
        });
        if (existingByLegacy) {
          this.logger.log(`User ${v1User.user_id} already migrated, skipping`);
          success++;
          continue;
        }

        // Use comprehensive data cleaning utility
        const cleaned = cleanUserData(v1User, v1User.user_id);
        
        // Log any issues found
        if (cleaned.issues.length > 0) {
          this.logger.warn(`User ${v1User.user_id}: Data issues - ${cleaned.issues.join(', ')}`);
        }
        
        let email = cleaned.email;
        let phoneNumber = cleaned.phoneNumber;
        
        // Check for duplicate phone number - if exists, make phone unique by appending user_id
        // NEVER skip a user - always create one, even if we have to modify contact info
        if (phoneNumber) {
          const existingUser = await this.prisma.user.findUnique({
            where: { phoneNumber: phoneNumber },
          });
          if (existingUser) {
            // If existing user doesn't have legacy_id, update it and skip creating duplicate
            if (!existingUser.legacyId) {
              await this.prisma.user.update({
                where: { id: existingUser.id },
                data: { legacyId: v1User.user_id },
              });
              this.logger.log(`Updated existing user ${existingUser.id} with legacy_id ${v1User.user_id}`);
              success++;
              continue;
            } else {
              // Duplicate phone - make it unique by appending user_id
              phoneNumber = `${phoneNumber}_${v1User.user_id}`;
              this.logger.warn(`User ${v1User.user_id} has duplicate phone, using: ${phoneNumber}`);
            }
          }
        }
        
        // Check for duplicate email - if exists, set to null (user must have phone to satisfy CHECK constraint)
        // NEVER skip a user - always create one
        if (email) {
          const existingUser = await this.prisma.user.findFirst({
            where: { email: email },
          });
          if (existingUser) {
            // If existing user doesn't have legacy_id, update it and skip creating duplicate
            if (!existingUser.legacyId) {
              await this.prisma.user.update({
                where: { id: existingUser.id },
                data: { legacyId: v1User.user_id },
              });
              this.logger.log(`Updated existing user ${existingUser.id} with legacy_id ${v1User.user_id}`);
              success++;
              continue;
            } else {
              // Duplicate email - set to null (user must have phone number)
              if (!phoneNumber) {
                // No phone either - generate placeholder phone
                phoneNumber = `250999${String(v1User.user_id).padStart(6, '0')}`;
                this.logger.warn(`User ${v1User.user_id} has duplicate email and no phone, using placeholder phone: ${phoneNumber}`);
              }
              email = null; // Set email to null for duplicate
              this.logger.warn(`User ${v1User.user_id} has duplicate email (${existingUser.email}), setting email to null (has phone: ${phoneNumber ? 'yes' : 'no'})`);
            }
          }
        }

        // Use cleaned full name
        let fullName = cleaned.fullName;
        
        // Check if we have minimum required data
        const hasName = cleaned.firstName || cleaned.lastName;
        const hasContact = cleaned.hasValidContact;
        
        // If no name, generate one
        if (!fullName) {
          fullName = `User ${v1User.user_id}`;
        }

        // Map account type to roles
        const roles = v1User.account_type === 'Merchant' 
          ? ['merchant'] 
          : ['explorer'];

        // Migrate profile images
        let profileImageId = null;
        if (v1User.user_profile_picture) {
          profileImageId = await createMediaRecordFromV1Url(
            v1User.user_profile_picture,
            {
              altText: fullName || 'Profile picture',
              category: 'profile',
            },
            this.prisma
          );
        }

        let backgroundImageId = null;
        if (v1User.user_profile_cover) {
          backgroundImageId = await createMediaRecordFromV1Url(
            v1User.user_profile_cover,
            {
              altText: fullName || 'Background image',
              category: 'profile',
            },
            this.prisma
          );
        }

        // Set default password for all migrated users: "Pass123"
        // Users will be prompted to change password on first login
        const defaultPassword = 'Pass123';
        const passwordHash = await bcrypt.hash(defaultPassword, 10);

        // Determine if user should be active (only if we have good data)
        const hasGoodData = hasName && hasContact && v1User.user_status === 'active';
        const isActive = hasGoodData;
        
        // If missing name, generate one
        if (!hasName && hasContact) {
          const generatedName = phoneNumber 
            ? `User ${phoneNumber.slice(-4)}` 
            : v1User.user_email?.split('@')[0] || `User ${v1User.user_id}`;
          fullName = generatedName;
        }

        // Create user in V2 - ALWAYS create, never skip
        // Final check: if email still exists in DB (race condition), set to null
        let finalEmail = email;
        if (finalEmail) {
          try {
            const lastCheck = await this.prisma.user.findFirst({
              where: { email: finalEmail },
            });
            if (lastCheck) {
              finalEmail = null; // Set to null if still duplicate
              this.logger.warn(`User ${v1User.user_id}: Final check - email ${email} exists, setting to null`);
              if (!phoneNumber) {
                phoneNumber = `250999${String(v1User.user_id).padStart(6, '0')}`;
              }
            }
          } catch (error: any) {
            // If check fails, assume duplicate and set to null to be safe
            this.logger.warn(`User ${v1User.user_id}: Final email check failed, setting to null: ${error.message}`);
            finalEmail = null;
            if (!phoneNumber) {
              phoneNumber = `250999${String(v1User.user_id).padStart(6, '0')}`;
            }
          }
        }
        
        // Ensure we have either email OR phone (CHECK constraint requirement)
        if (!finalEmail && !phoneNumber) {
          phoneNumber = `250999${String(v1User.user_id).padStart(6, '0')}`;
        }
        
        // Try to create user - if unique constraint fails on email, retry with email = null
        let v2User;
        try {
          v2User = await this.prisma.user.create({
            data: {
              legacyId: v1User.user_id,
              email: finalEmail, // Use final processed email (may be null if duplicate)
              phoneNumber: phoneNumber || null,
            firstName: cleaned.firstName,
            lastName: cleaned.lastName,
            fullName: cleaned.fullName, // Always have a name (generated if missing)
              gender: v1User.user_gender || null,
              address: v1User.user_location || null,
              passwordHash: passwordHash, // Set default password "Pass123"
              legacyPasswordHash: v1User.user_password || null, // Keep for reference
              passwordMigrated: true, // Mark as migrated (using new password)
              roles: roles as any,
              isActive: isActive, // Set to inactive if missing data
              createdAt: v1User.user_reg_date ? new Date(v1User.user_reg_date) : new Date(),
              profileImageId: profileImageId,
              backgroundImageId: backgroundImageId,
            },
          });
        } catch (createError: any) {
          // If unique constraint on email, retry with email = null
          if (createError.code === 'P2002' && createError.meta?.target?.includes('email') && finalEmail) {
            this.logger.warn(`User ${v1User.user_id}: Unique constraint on email, retrying with email = null`);
            finalEmail = null;
            if (!phoneNumber) {
              phoneNumber = `250999${String(v1User.user_id).padStart(6, '0')}`;
            }
            // Retry creation with email = null
            v2User = await this.prisma.user.create({
              data: {
                legacyId: v1User.user_id,
                email: null, // Set to null due to unique constraint
                phoneNumber: phoneNumber || null,
                firstName: v1User.user_fname || null,
                lastName: v1User.user_lname || null,
                fullName: fullName || `User ${v1User.user_id}`,
                gender: v1User.user_gender || null,
                address: v1User.user_location || null,
                passwordHash: passwordHash,
                legacyPasswordHash: v1User.user_password || null,
                passwordMigrated: true,
                roles: roles as any,
                isActive: isActive,
                createdAt: v1User.user_reg_date ? new Date(v1User.user_reg_date) : new Date(),
                profileImageId: profileImageId,
                backgroundImageId: backgroundImageId,
              },
            });
          } else {
            // Re-throw if it's not an email unique constraint
            throw createError;
          }
        }

        this.logger.log(`Migrated user ${v1User.user_id} → ${v2User.id}`);
        success++;
      } catch (error: any) {
        // Try one more time with minimal data if first attempt failed
        try {
          this.logger.warn(`Retrying user ${v1User.user_id} with minimal data`);
          const defaultPassword = 'Pass123';
          const passwordHash = await bcrypt.hash(defaultPassword, 10);
          
          // Use data cleaning utility for retry
          const retryCleaned = cleanUserData(v1User, v1User.user_id);
          
          // For retry, always set email to null to avoid duplicates
          const retryEmail = null;
          let retryPhone = retryCleaned.phoneNumber || `250999${String(v1User.user_id).padStart(6, '0')}`;
          
          // Check if phone exists, modify if needed
          const existingPhone = await this.prisma.user.findUnique({
            where: { phoneNumber: retryPhone },
          });
          if (existingPhone) {
            retryPhone = `${retryPhone}_${v1User.user_id}`;
          }
          
          const retryFullName = retryCleaned.fullName;
          
          const retryUser = await this.prisma.user.create({
            data: {
              legacyId: v1User.user_id,
              email: retryEmail, // Always null in retry to avoid duplicates
              phoneNumber: retryPhone,
              firstName: v1User.user_fname || null,
              lastName: v1User.user_lname || null,
              fullName: retryFullName,
              passwordHash: passwordHash,
              passwordMigrated: true,
              roles: (v1User.account_type === 'Merchant' ? ['merchant'] : ['explorer']) as any,
              isActive: false, // Inactive due to retry
              createdAt: v1User.user_reg_date ? new Date(v1User.user_reg_date) : new Date(),
            },
          });
          
          this.logger.log(`Migrated user ${v1User.user_id} → ${retryUser.id} (retry with minimal data, email=null)`);
          success++;
        } catch (retryError: any) {
          // If still unique constraint on email, try one more time with email definitely null
          if (retryError.code === 'P2002' || retryError.message?.includes('Unique constraint')) {
            try {
              this.logger.warn(`User ${v1User.user_id}: Final retry with email=null and unique phone`);
              const defaultPassword = 'Pass123';
              const passwordHash = await bcrypt.hash(defaultPassword, 10);
              const finalPhone = `250999${String(v1User.user_id).padStart(6, '0')}`;
              const retryFullName = [v1User.user_fname, v1User.user_lname]
                .filter(Boolean)
                .join(' ')
                .trim() || `User ${v1User.user_id}`;
              
              const finalRetryUser = await this.prisma.user.create({
                data: {
                  legacyId: v1User.user_id,
                  email: null, // Definitely null
                  phoneNumber: finalPhone, // Unique phone
                  firstName: v1User.user_fname || null,
                  lastName: v1User.user_lname || null,
                  fullName: retryFullName,
                  passwordHash: passwordHash,
                  passwordMigrated: true,
                  roles: (v1User.account_type === 'Merchant' ? ['merchant'] : ['explorer']) as any,
                  isActive: false,
                  createdAt: v1User.user_reg_date ? new Date(v1User.user_reg_date) : new Date(),
                },
              });
              
              this.logger.log(`Migrated user ${v1User.user_id} → ${finalRetryUser.id} (final retry with email=null)`);
              success++;
            } catch (finalError: any) {
              this.logger.error(`Failed to migrate user ${v1User.user_id} even with final retry:`, finalError.message);
              failed++;
            }
          } else {
            this.logger.error(`Failed to migrate user ${v1User.user_id} even with retry:`, retryError.message);
            failed++;
          }
        }
      }
    }

    this.logger.log(`Migrated ${success} users, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Migrate venues to listings
   */
  async migrateVenues(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [rows] = await this.v1Connection.execute('SELECT * FROM venues');
    const venues = rows as any[];

    // Group venues by user_id
    const venuesByUser = new Map<number, any[]>();
    for (const venue of venues) {
      if (!venuesByUser.has(venue.user_id)) {
        venuesByUser.set(venue.user_id, []);
      }
      venuesByUser.get(venue.user_id)!.push(venue);
    }

    let success = 0;
    let failed = 0;

    // Process each user's venues
    for (const [userId, userVenues] of venuesByUser) {
      try {
        // Get V2 user UUID
        let v2User = await this.prisma.user.findUnique({
          where: { legacyId: userId },
        });

        // If user not found, CREATE IT - we cannot lose any venue
        if (!v2User) {
          this.logger.warn(`User ${userId} not found in V2, attempting to create from venue data`);
          
          // Try to create user from venue data
          // Find venue with best data (name + phone/email)
          const venueWithData = userVenues.find(
            (v) => v.venue_name && (v.venue_phone || v.venue_email)
          ) || userVenues.find((v) => v.venue_name || v.venue_phone || v.venue_email) || userVenues[0];
          
          if (venueWithData) {
            try {
              const createdUser = await this.createUserFromVenueData(userId, venueWithData);
              if (createdUser) {
                this.logger.log(`Created user ${createdUser.id} from venue data for user_id ${userId}`);
                // Update the v2User reference
                const updatedV2User = await this.prisma.user.findUnique({
                  where: { id: createdUser.id },
                });
                if (updatedV2User) {
                  // Continue with this user
                  const merchantMap = await batchCreateMerchantProfilesForUser(
                    updatedV2User.id,
                    userVenues.map((v) => ({
                      venue_id: v.venue_id,
                      venue_name: v.venue_name,
                      category_id: v.category_id,
                      venue_email: v.venue_email,
                      venue_phone: v.venue_phone,
                      venue_website: v.venue_website,
                      country_id: v.country_id,
                      location_id: v.location_id,
                    })),
                    { type: 'one_per_venue' },
                    this.prisma
                  );

                  // Migrate each venue to listing
                  for (const venue of userVenues) {
                    try {
                      const existingListing = await this.prisma.listing.findFirst({
                        where: { legacyId: venue.venue_id },
                      });
                      if (existingListing) {
                        this.logger.log(`Venue ${venue.venue_id} already migrated, skipping`);
                        success++;
                        continue;
                      }

                      await this.migrateVenueToListing(venue, merchantMap.get(venue.venue_id), true); // Pass inactive flag
                      success++;
                    } catch (error: any) {
                      this.logger.error(`Failed to migrate venue ${venue.venue_id}:`, error.message);
                      failed++;
                    }
                  }
                  continue;
                }
              }
            } catch (error: any) {
              this.logger.error(`Failed to create user from venue data for user_id ${userId}:`, error.message);
            }
          }
          
          // If we still can't create user, try to migrate venues anyway with minimal data
          // Create a placeholder user
          try {
            const placeholderUser = await this.createUserFromVenueData(userId, {
              venue_name: `Business ${userId}`,
              venue_phone: null,
              venue_email: null,
            });
            
            if (placeholderUser) {
              const merchantMap = await batchCreateMerchantProfilesForUser(
                placeholderUser.id,
                userVenues.map((v) => ({
                  venue_id: v.venue_id,
                  venue_name: v.venue_name || `Venue ${v.venue_id}`,
                  category_id: v.category_id,
                  venue_email: v.venue_email,
                  venue_phone: v.venue_phone,
                  venue_website: v.venue_website,
                  country_id: v.country_id,
                  location_id: v.location_id,
                })),
                { type: 'one_per_venue' },
                this.prisma
              );

              for (const venue of userVenues) {
                try {
                  const existingListing = await this.prisma.listing.findFirst({
                    where: { legacyId: venue.venue_id },
                  });
                  if (existingListing) {
                    success++;
                    continue;
                  }

                  await this.migrateVenueToListing(venue, merchantMap.get(venue.venue_id), true);
                  success++;
                } catch (error: any) {
                  this.logger.error(`Failed to migrate venue ${venue.venue_id}:`, error.message);
                  failed++;
                }
              }
              continue;
            }
          } catch (error: any) {
            this.logger.error(`Failed to create placeholder user for user_id ${userId}:`, error.message);
          }
          
          // Last resort: create minimal user and migrate venues anyway
          this.logger.warn(`User ${userId} not found, creating minimal user`);
          try {
            const defaultPassword = 'Pass123';
            const passwordHash = await bcrypt.hash(defaultPassword, 10);
            
            v2User = await this.prisma.user.create({
              data: {
                legacyId: userId,
                email: null,
                phoneNumber: null,
                fullName: `Business Owner ${userId}`,
                firstName: null,
                lastName: null,
                passwordHash: passwordHash,
                passwordMigrated: true,
                roles: ['merchant'] as any,
                isActive: false,
                createdAt: new Date(),
              },
            });
            this.logger.log(`Created minimal user ${v2User.id} for user_id ${userId}`);
          } catch (error: any) {
            this.logger.error(`Failed to create minimal user ${userId}:`, error.message);
            // Still try to migrate venues without user
            for (const venue of userVenues) {
              try {
                const existingListing = await this.prisma.listing.findFirst({
                  where: { legacyId: venue.venue_id },
                });
                if (existingListing) {
                  success++;
                  continue;
                }
                await this.migrateVenueToListing(venue, undefined, true);
                success++;
              } catch (error: any) {
                this.logger.error(`Failed to migrate venue ${venue.venue_id}:`, error.message);
                failed++;
              }
            }
            continue;
          }
        }

        // Create merchant profiles for this user's venues
        const merchantMap = await batchCreateMerchantProfilesForUser(
          v2User.id,
          userVenues.map((v) => ({
            venue_id: v.venue_id,
            venue_name: v.venue_name,
            category_id: v.category_id,
            venue_email: v.venue_email,
            venue_phone: v.venue_phone,
            venue_website: v.venue_website,
            country_id: v.country_id,
            location_id: v.location_id,
          })),
          { type: 'one_per_venue' },
          this.prisma
        );

        // Migrate each venue to listing
        for (const venue of userVenues) {
          try {
            // Check if listing already migrated by legacy_id
            const existingListing = await this.prisma.listing.findFirst({
              where: { legacyId: venue.venue_id },
            });
            if (existingListing) {
              this.logger.log(`Venue ${venue.venue_id} already migrated, skipping`);
              success++;
              continue;
            }

            await this.migrateVenueToListing(venue, merchantMap.get(venue.venue_id));
            success++;
          } catch (error: any) {
            this.logger.error(`Failed to migrate venue ${venue.venue_id}:`, error.message);
            failed++;
          }
        }
      } catch (error: any) {
        this.logger.error(`Failed to process venues for user ${userId}:`, error.message);
        failed += userVenues.length;
      }
    }

    this.logger.log(`Migrated ${success} venues, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Create user from venue data when user doesn't exist
   */
  private async createUserFromVenueData(v1UserId: number, venue: any): Promise<any> {
    try {
      // Check if user already exists by legacy_id
      const existing = await this.prisma.user.findUnique({
        where: { legacyId: v1UserId },
      });
      if (existing) {
        return existing;
      }

      // Generate user data from venue
      const venueName = venue.venue_name?.trim() || `Business ${v1UserId}`;
      const venuePhone = venue.venue_phone?.trim() || null;
      const venueEmail = venue.venue_email?.trim() || null;

      // Clean phone number
      let phoneNumber = venuePhone;
      if (phoneNumber && !phoneNumber.startsWith('+')) {
        // Remove any non-digit characters except +
        phoneNumber = phoneNumber.replace(/[^\d+]/g, '');
        if (!phoneNumber.startsWith('+')) {
          phoneNumber = '250' + phoneNumber.replace(/^0+/, '');
        }
      }

      // Check for duplicate phone
      if (phoneNumber) {
        const existingByPhone = await this.prisma.user.findUnique({
          where: { phoneNumber: phoneNumber },
        });
        if (existingByPhone) {
          // Update with legacy_id if missing
          if (!existingByPhone.legacyId) {
            await this.prisma.user.update({
              where: { id: existingByPhone.id },
              data: { legacyId: v1UserId },
            });
          }
          return existingByPhone;
        }
      }

      // Check for duplicate email
      if (venueEmail) {
        const existingByEmail = await this.prisma.user.findFirst({
          where: { email: venueEmail },
        });
        if (existingByEmail) {
          // Update with legacy_id if missing
          if (!existingByEmail.legacyId) {
            await this.prisma.user.update({
              where: { id: existingByEmail.id },
              data: { legacyId: v1UserId },
            });
          }
          return existingByEmail;
        }
      }

      // Generate password
      const defaultPassword = 'Pass123';
      const passwordHash = await bcrypt.hash(defaultPassword, 10);

      // Create user (will be inactive due to missing data)
      // If email already exists, set to null to avoid unique constraint
      let finalEmail = venueEmail;
      if (finalEmail) {
        const emailExists = await this.prisma.user.findFirst({
          where: { email: finalEmail },
        });
        if (emailExists) {
          finalEmail = null; // Set to null if duplicate
        }
      }

      const user = await this.prisma.user.create({
        data: {
          legacyId: v1UserId,
          email: finalEmail,
          phoneNumber: phoneNumber,
          fullName: venueName,
          firstName: venueName.split(' ')[0] || null,
          lastName: venueName.split(' ').slice(1).join(' ') || null,
          passwordHash: passwordHash,
          passwordMigrated: true,
          roles: ['merchant'] as any,
          isActive: false, // Inactive because created from venue data
          createdAt: new Date(),
        },
      });

      return user;
    } catch (error: any) {
      this.logger.error(`Failed to create user from venue data:`, error.message);
      return null;
    }
  }

  /**
   * Migrate a single venue to listing - ALWAYS creates listing, never skips
   */
  async migrateVenueToListing(venue: any, merchantId: string | undefined, forceInactive: boolean = false): Promise<void> {
    // Generate venue name - ensure we always have a name
    const venueName = venue.venue_name?.trim() || `Venue ${venue.venue_id}`;
    
    // Allow null merchant if user doesn't exist - we still migrate the venue
    // if (!merchantId && !forceInactive) {
    //   throw new Error(`No merchant profile found for venue ${venue.venue_id}`);
    // }

    // Map country and city
    const countryId = await getOrCreateCountry(venue.country_id, this.prisma);
    const cityId = await getOrCreateCity(venue.location_id, venue.country_id, this.prisma);

    // Convert coordinates
    const coords = this.convertCoordinates(venue.venue_coordinates);

    // Generate slug from name - truncate to 255 chars
    const baseSlug = venue.venue_code || 
      venueName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || `venue-${venue.venue_id}`;
    const slug = baseSlug.substring(0, 255);

    // Migrate images
    let primaryImageId = null;
    if (venue.venue_image) {
      primaryImageId = await createMediaRecordFromV1Url(
        venue.venue_image,
        {
          altText: venueName,
          category: 'venue',
        },
        this.prisma
      );
    }

    // Parse working hours (if stored as text, convert to JSONB)
    let operatingHours = null;
    if (venue.working_hours) {
      try {
        operatingHours = JSON.parse(venue.working_hours);
      } catch {
        // If not JSON, create default structure
        operatingHours = {
          monday: { open: '09:00', close: '18:00', closed: false },
          tuesday: { open: '09:00', close: '18:00', closed: false },
          wednesday: { open: '09:00', close: '18:00', closed: false },
          thursday: { open: '09:00', close: '18:00', closed: false },
          friday: { open: '09:00', close: '18:00', closed: false },
          saturday: { open: '09:00', close: '18:00', closed: false },
          sunday: { open: '09:00', close: '18:00', closed: false },
        };
      }
    }

    // Map status - set to inactive if forced or if missing critical data
    const hasGoodData = venue.venue_name && (venue.venue_phone || venue.venue_email);
    let status: 'draft' | 'pending_review' | 'active' | 'inactive' = 'pending_review';
    
    if (forceInactive || !hasGoodData) {
      status = 'inactive';
    } else if (venue.venue_status === 'active') {
      status = 'active';
    }

    // Create listing (without location first, then update with PostGIS geography)
    // ALWAYS create listing, even with minimal data
    // Truncate fields to fit database constraints
    const truncatedName = venueName.substring(0, 255);
    const truncatedDescription = venue.venue_about ? venue.venue_about.substring(0, 5000) : null;
    const truncatedShortDesc = venue.venue_about 
      ? venue.venue_about.substring(0, 500) 
      : null;
    const truncatedAddress = venue.venue_address ? venue.venue_address.substring(0, 500) : null;
    
    const listing = await this.prisma.listing.create({
      data: {
        legacyId: venue.venue_id,
        merchantId: merchantId || null, // Allow null merchant if user doesn't exist
        name: truncatedName, // Use truncated venueName
        slug: slug,
        description: truncatedDescription,
        shortDescription: truncatedShortDesc,
        countryId: countryId,
        cityId: cityId,
        address: truncatedAddress,
        // location will be set via raw SQL if coordinates exist
        minPrice: venue.venue_price ? parseFloat(venue.venue_price.toString()) : null,
        maxPrice: venue.venue_price ? parseFloat(venue.venue_price.toString()) : null,
        currency: 'RWF',
        contactPhone: venue.venue_phone ? venue.venue_phone.substring(0, 20) : null,
        contactEmail: venue.venue_email ? venue.venue_email.substring(0, 255) : null,
        website: venue.venue_website ? venue.venue_website.substring(0, 500) : null,
        operatingHours: operatingHours as any,
        rating: venue.venue_rating ? parseFloat(venue.venue_rating.toString()) / 5.0 : 0,
        reviewCount: venue.venue_reviews || 0,
        status: status as any,
        createdAt: venue.time_added ? new Date(venue.time_added) : new Date(),
      },
    });

    // Update location with PostGIS geography if coordinates exist
    if (coords) {
      try {
        // Use Prisma.$executeRawUnsafe for PostGIS geography
        // ST_GeogFromText expects text, not geography type
        await this.prisma.$executeRawUnsafe(
          `UPDATE listings 
           SET location = ST_GeogFromText($1)::geography
           WHERE id = $2::uuid`,
          `POINT(${coords.lng} ${coords.lat})`,
          listing.id
        );
      } catch (error) {
        this.logger.warn(`Failed to set location for listing ${listing.id}:`, error);
      }
    }

    // Create primary image relationship
    if (primaryImageId) {
      await this.prisma.listingImage.create({
        data: {
          listingId: listing.id,
          mediaId: primaryImageId,
          isPrimary: true,
          sortOrder: 0,
        },
      });
    }

    // Migrate banner image if exists
    if (venue.banner_url) {
      const bannerImageId = await createMediaRecordFromV1Url(
        venue.banner_url,
        {
          altText: `${venue.venue_name} banner`,
          category: 'venue',
        },
        this.prisma
      );
      if (bannerImageId) {
        await this.prisma.listingImage.create({
          data: {
            listingId: listing.id,
            mediaId: bannerImageId,
            isPrimary: false,
            sortOrder: 1,
          },
        });
      }
    }

    // TODO: Parse facilities and create listing_amenities relationships
    // TODO: Map category_id to V2 category

    this.logger.log(`Migrated venue ${venue.venue_id} → listing ${listing.id}`);
  }

  /**
   * Migrate bookings from V1 to V2
   */
  async migrateBookings(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [rows] = await this.v1Connection.execute('SELECT * FROM bookings');
    const bookings = rows as any[];

    let success = 0;
    let failed = 0;

    for (const v1Booking of bookings) {
      try {
        // Check if booking already migrated by legacy_id
        const existingBooking = await this.prisma.booking.findUnique({
          where: { legacyId: v1Booking.booking_id },
        });
        if (existingBooking) {
          this.logger.log(`Booking ${v1Booking.booking_id} already migrated, skipping`);
          success++;
          continue;
        }

        // Get V2 user UUID
        const v2User = await this.prisma.user.findUnique({
          where: { legacyId: v1Booking.user_id },
        });

        if (!v2User) {
          this.logger.warn(`User ${v1Booking.user_id} not found for booking ${v1Booking.booking_id}`);
          failed++;
          continue;
        }

        // Get V2 listing UUID from venue_id
        const v2Listing = await this.prisma.listing.findFirst({
          where: { legacyId: v1Booking.venue_id },
        });

        if (!v2Listing) {
          this.logger.warn(`Listing for venue ${v1Booking.venue_id} not found for booking ${v1Booking.booking_id}`);
          failed++;
          continue;
        }

        // Parse dates (handle '0000-00-00' invalid dates)
        let checkInDate: Date | null = null;
        let checkOutDate: Date | null = null;

        if (v1Booking.checkin_date && v1Booking.checkin_date !== '0000-00-00') {
          try {
            checkInDate = new Date(v1Booking.checkin_date);
            if (isNaN(checkInDate.getTime())) {
              checkInDate = null;
            }
          } catch {
            checkInDate = null;
          }
        }

        if (v1Booking.checkout_date && v1Booking.checkout_date !== '0000-00-00') {
          try {
            checkOutDate = new Date(v1Booking.checkout_date);
            if (isNaN(checkOutDate.getTime())) {
              checkOutDate = null;
            }
          } catch {
            checkOutDate = null;
          }
        }

        // Map booking status
        let status: 'pending' | 'confirmed' | 'cancelled' | 'completed' = 'pending';
        const v1Status = (v1Booking.booking_status || '').toLowerCase();
        if (v1Status.includes('booked') || v1Status.includes('confirmed')) {
          status = 'confirmed';
        } else if (v1Status.includes('cancel')) {
          status = 'cancelled';
        } else if (v1Status.includes('complete')) {
          status = 'completed';
        }

        // Generate booking number if missing
        const bookingNumber = v1Booking.booking_no || `BK-${v1Booking.booking_id}-${Date.now()}`;

        // Calculate guest count
        const guestCount = (v1Booking.adults || 0) + (v1Booking.children || 0);

        // Create booking in V2
        const v2Booking = await this.prisma.booking.create({
          data: {
            legacyId: v1Booking.booking_id,
            userId: v2User.id,
            listingId: v2Listing.id,
            bookingNumber: bookingNumber,
            // type field doesn't exist in V2 Booking model - it's inferred from listing
            status: status as any,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            guestCount: guestCount,
            adults: v1Booking.adults || 1,
            children: v1Booking.children || 0,
            specialRequests: v1Booking.additional_request || null,
            totalAmount: 0, // V1 doesn't have amount, set to 0
            currency: 'RWF',
            paymentStatus: (v1Booking.payment_status === 'Paid' ? 'completed' : 'pending') as any,
            createdAt: v1Booking.booking_time ? new Date(v1Booking.booking_time) : new Date(),
          },
        });

        this.logger.log(`Migrated booking ${v1Booking.booking_id} → ${v2Booking.id}`);
        success++;
      } catch (error: any) {
        this.logger.error(`Failed to migrate booking ${v1Booking.booking_id}:`, error.message);
        failed++;
      }
    }

    this.logger.log(`Migrated ${success} bookings, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Migrate reviews from V1 to V2
   */
  async migrateReviews(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [rows] = await this.v1Connection.execute('SELECT * FROM reviews');
    const reviews = rows as any[];

    let success = 0;
    let failed = 0;

    for (const v1Review of reviews) {
      try {
        // Check if review already migrated by legacy_id
        const existingReview = await this.prisma.review.findUnique({
          where: { legacyId: v1Review.review_id },
        });
        if (existingReview) {
          this.logger.log(`Review ${v1Review.review_id} already migrated, skipping`);
          success++;
          continue;
        }

        // Get V2 user UUID
        const v2User = await this.prisma.user.findUnique({
          where: { legacyId: v1Review.user_id },
        });

        if (!v2User) {
          this.logger.warn(`User ${v1Review.user_id} not found for review ${v1Review.review_id}`);
          failed++;
          continue;
        }

        // Get V2 listing UUID from venue_id
        const v2Listing = await this.prisma.listing.findFirst({
          where: { legacyId: v1Review.venue_id },
        });

        if (!v2Listing) {
          this.logger.warn(`Listing for venue ${v1Review.venue_id} not found for review ${v1Review.review_id}`);
          failed++;
          continue;
        }

        // Parse rating (handle string ratings)
        let rating = parseFloat(v1Review.rating);
        if (isNaN(rating) || rating < 1 || rating > 5) {
          rating = 5; // Default to 5 if invalid
        }

        // Clean review text (some reviews have phone numbers instead of text)
        let reviewText = v1Review.review?.trim() || '';
        // If review looks like a phone number, skip it
        if (/^[\d\s\+\-\(\)]+$/.test(reviewText) && reviewText.length < 20) {
          reviewText = ''; // Empty if it's just a phone number
        }

        // Map review status
        const isApproved = (v1Review.review_status || '').toLowerCase() === 'approved';

        // Create review in V2
        const v2Review = await this.prisma.review.create({
          data: {
            legacyId: v1Review.review_id,
            userId: v2User.id,
            listingId: v2Listing.id,
            rating: rating,
            content: reviewText || 'No comment', // V2 uses 'content' field
            status: isApproved ? 'approved' : 'pending', // V2 uses 'status' field, not 'isApproved'
            createdAt: v1Review.review_time ? new Date(v1Review.review_time) : new Date(),
          },
        });

        this.logger.log(`Migrated review ${v1Review.review_id} → ${v2Review.id}`);
        success++;
      } catch (error: any) {
        this.logger.error(`Failed to migrate review ${v1Review.review_id}:`, error.message);
        failed++;
      }
    }

    this.logger.log(`Migrated ${success} reviews, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Migrate favorites from V1 to V2
   */
  async migrateFavorites(): Promise<{ success: number; failed: number }> {
    if (!this.v1Connection) {
      throw new Error('V1 database not connected');
    }

    const [rows] = await this.v1Connection.execute('SELECT * FROM favorites');
    const favorites = rows as any[];

    // Remove duplicates (same user + venue combination)
    const uniqueFavorites = this.removeDuplicates(
      favorites,
      (fav: any) => `${fav.user_id}-${fav.venue_id}`
    );

    let success = 0;
    let failed = 0;

    for (const v1Favorite of uniqueFavorites) {
      try {
        // Check if favorite already migrated by legacy_id
        const existingFavorite = await this.prisma.favorite.findUnique({
          where: { legacyId: v1Favorite.favorite_id },
        });
        if (existingFavorite) {
          this.logger.log(`Favorite ${v1Favorite.favorite_id} already migrated, skipping`);
          success++;
          continue;
        }

        // Get V2 user UUID
        const v2User = await this.prisma.user.findUnique({
          where: { legacyId: v1Favorite.user_id },
        });

        if (!v2User) {
          this.logger.warn(`User ${v1Favorite.user_id} not found for favorite ${v1Favorite.favorite_id}`);
          failed++;
          continue;
        }

        // Get V2 listing UUID from venue_id
        const v2Listing = await this.prisma.listing.findFirst({
          where: { legacyId: v1Favorite.venue_id },
        });

        if (!v2Listing) {
          this.logger.warn(`Listing for venue ${v1Favorite.venue_id} not found for favorite ${v1Favorite.favorite_id}`);
          failed++;
          continue;
        }

        // Check if favorite already exists
        const existing = await this.prisma.favorite.findFirst({
          where: {
            userId: v2User.id,
            listingId: v2Listing.id,
          },
        });

        if (existing) {
          // Update legacy_id if missing
          if (!existing.legacyId) {
            await this.prisma.favorite.update({
              where: { id: existing.id },
              data: { legacyId: v1Favorite.favorite_id },
            });
          }
          success++;
          continue;
        }

        // Create favorite in V2
        const v2Favorite = await this.prisma.favorite.create({
          data: {
            legacyId: v1Favorite.favorite_id,
            userId: v2User.id,
            listingId: v2Listing.id,
            createdAt: new Date(),
          },
        });

        this.logger.log(`Migrated favorite ${v1Favorite.favorite_id} → ${v2Favorite.id}`);
        success++;
      } catch (error: any) {
        this.logger.error(`Failed to migrate favorite ${v1Favorite.favorite_id}:`, error.message);
        failed++;
      }
    }

    this.logger.log(`Migrated ${success} favorites, ${failed} failed`);
    return { success, failed };
  }

  /**
   * Run complete migration
   */
  async runMigration(v1Config: {
    host: string;
    port: number;
    user: string;
    password: string;
    database: string;
  }): Promise<{
    countries: { success: number; failed: number };
    cities: { success: number; failed: number };
    users: { success: number; failed: number };
    venues: { success: number; failed: number };
    bookings: { success: number; failed: number };
    reviews: { success: number; failed: number };
    favorites: { success: number; failed: number };
  }> {
    this.logger.log('Starting V1 → V2 migration...');

    try {
      await this.connectV1(v1Config);

      const countries = await this.migrateCountries();
      const cities = await this.migrateCities();
      const users = await this.migrateUsers();
      const venues = await this.migrateVenues();
      const bookings = await this.migrateBookings();
      const reviews = await this.migrateReviews();
      const favorites = await this.migrateFavorites();

      this.logger.log('Migration completed!');
      return { countries, cities, users, venues, bookings, reviews, favorites };
    } finally {
      await this.disconnectV1();
    }
  }
}

