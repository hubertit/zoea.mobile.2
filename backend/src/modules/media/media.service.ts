import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { v2 as cloudinary, UploadApiResponse } from 'cloudinary';
import { Readable } from 'stream';

interface CloudinaryAccount {
  name: string;
  cloudName: string;
  apiKey: string;
  apiSecret: string;
  maxStorageGB: number;
  isActive: boolean;
}

@Injectable()
export class MediaService {
  private readonly logger = new Logger(MediaService.name);
  private accounts: CloudinaryAccount[] = [];

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.loadAccounts();
  }

  private loadAccounts() {
    // Load accounts from environment variables
    // Format: CLOUDINARY_ACCOUNTS=[{"name":"account1","cloudName":"xxx","apiKey":"xxx","apiSecret":"xxx","maxStorageGB":25}]
    const accountsJson = this.configService.get<string>('CLOUDINARY_ACCOUNTS');
    
    if (accountsJson) {
      try {
        this.accounts = JSON.parse(accountsJson);
        this.logger.log(`Loaded ${this.accounts.length} Cloudinary accounts`);
      } catch (e) {
        this.logger.error('Failed to parse CLOUDINARY_ACCOUNTS', e);
      }
    }

    // Fallback to single account config
    if (this.accounts.length === 0) {
      const cloudName = this.configService.get<string>('CLOUDINARY_CLOUD_NAME');
      const apiKey = this.configService.get<string>('CLOUDINARY_API_KEY');
      const apiSecret = this.configService.get<string>('CLOUDINARY_API_SECRET');

      if (cloudName && apiKey && apiSecret) {
        this.accounts.push({
          name: 'primary',
          cloudName,
          apiKey,
          apiSecret,
          maxStorageGB: 25,
          isActive: true,
        });
        this.logger.log('Loaded single Cloudinary account from env');
      }
    }
  }

  private configureCloudinary(account: CloudinaryAccount) {
    cloudinary.config({
      cloud_name: account.cloudName,
      api_key: account.apiKey,
      api_secret: account.apiSecret,
      secure: true,
    });
  }

  async getAccountStats(): Promise<any[]> {
    const stats = [];

    for (const account of this.accounts) {
      // Get file count and estimated storage from database
      const mediaCount = await this.prisma.media.count({
        where: { storageProvider: account.name },
      });

      const storageUsed = await this.prisma.media.aggregate({
        where: { storageProvider: account.name },
        _sum: { fileSize: true },
      });

      const usedGB = (storageUsed._sum.fileSize || 0) / (1024 * 1024 * 1024);

      stats.push({
        name: account.name,
        cloudName: account.cloudName,
        usedStorageGB: Math.round(usedGB * 100) / 100,
        maxStorageGB: account.maxStorageGB,
        availableStorageGB: Math.round((account.maxStorageGB - usedGB) * 100) / 100,
        fileCount: mediaCount,
        isActive: account.isActive,
        usagePercent: Math.round((usedGB / account.maxStorageGB) * 100),
      });
    }

    return stats;
  }

  private async getAvailableAccount(): Promise<CloudinaryAccount | null> {
    const stats = await this.getAccountStats();

    // Find account with most available space that's under 90% usage
    const available = stats
      .filter(s => s.isActive && s.usagePercent < 90)
      .sort((a, b) => b.availableStorageGB - a.availableStorageGB);

    if (available.length === 0) {
      // All accounts full, use the one with most space anyway
      const fallback = stats.filter(s => s.isActive).sort((a, b) => b.availableStorageGB - a.availableStorageGB)[0];
      if (fallback) {
        return this.accounts.find(a => a.name === fallback.name) || null;
      }
      return null;
    }

    return this.accounts.find(a => a.name === available[0].name) || null;
  }

  async upload(
    file: Express.Multer.File,
    userId: string,
    options: { category?: string; altText?: string; title?: string; folder?: string } = {},
  ) {
    const account = await this.getAvailableAccount();

    if (!account) {
      throw new BadRequestException('No storage accounts available. Please configure Cloudinary accounts.');
    }

    this.configureCloudinary(account);

    // Determine resource type
    const mimeType = file.mimetype;
    let resourceType: 'image' | 'video' | 'raw' = 'image';
    let mediaType = 'image';

    if (mimeType.startsWith('video/')) {
      resourceType = 'video';
      mediaType = 'video';
    } else if (mimeType.startsWith('audio/')) {
      resourceType = 'video'; // Cloudinary uses video for audio
      mediaType = 'audio';
    } else if (!mimeType.startsWith('image/')) {
      resourceType = 'raw';
      mediaType = 'document';
    }

    // Upload to Cloudinary
    const folder = options.folder || `zoea/${options.category || 'uploads'}`;
    const uploadPreset = this.configService.get<string>('CLOUDINARY_UPLOAD_PRESET');

    try {
      const result = await new Promise<UploadApiResponse>((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder,
            resource_type: resourceType,
            public_id: `${Date.now()}_${file.originalname.replace(/\.[^/.]+$/, '')}`,
            ...(uploadPreset && { upload_preset: uploadPreset }),
          },
          (error, result) => {
            if (error) reject(error);
            else resolve(result!);
          },
        );

        const readable = new Readable();
        readable.push(file.buffer);
        readable.push(null);
        readable.pipe(uploadStream);
      });

      // Generate thumbnail URL for images
      let thumbnailUrl = null;
      if (mediaType === 'image') {
        thumbnailUrl = cloudinary.url(result.public_id, {
          width: 300,
          height: 300,
          crop: 'fill',
          quality: 'auto',
          format: 'auto',
        });
      }

      // Save to database
      const media = await this.prisma.media.create({
        data: {
          url: result.secure_url,
          thumbnailUrl,
          publicId: result.public_id,
          mediaType: mediaType as any,
          category: options.category,
          altText: options.altText,
          title: options.title,
          fileName: file.originalname,
          fileSize: result.bytes,
          mimeType: file.mimetype,
          width: result.width,
          height: result.height,
          storageProvider: account.name,
          uploadedBy: userId,
        },
      });

      return {
        id: media.id,
        url: media.url,
        thumbnailUrl: media.thumbnailUrl,
        type: media.mediaType,
        fileName: media.fileName,
        fileSize: media.fileSize,
        width: media.width,
        height: media.height,
        storageProvider: media.storageProvider,
      };
    } catch (error) {
      this.logger.error('Upload failed', error);
      throw new BadRequestException('Failed to upload file: ' + error.message);
    }
  }

  async uploadFromUrl(
    url: string,
    userId: string,
    options: { category?: string; altText?: string; title?: string; folder?: string } = {},
  ) {
    const account = await this.getAvailableAccount();

    if (!account) {
      throw new BadRequestException('No storage accounts available');
    }

    this.configureCloudinary(account);

    const folder = options.folder || `zoea/${options.category || 'uploads'}`;

    const uploadPreset = this.configService.get<string>('CLOUDINARY_UPLOAD_PRESET');

    try {
      const result = await cloudinary.uploader.upload(url, {
        folder,
        resource_type: 'auto',
        ...(uploadPreset && { upload_preset: uploadPreset }),
      });

      let mediaType = 'image';
      if (result.resource_type === 'video') {
        mediaType = result.format === 'mp3' || result.format === 'wav' ? 'audio' : 'video';
      } else if (result.resource_type === 'raw') {
        mediaType = 'document';
      }

      let thumbnailUrl = null;
      if (mediaType === 'image') {
        thumbnailUrl = cloudinary.url(result.public_id, {
          width: 300,
          height: 300,
          crop: 'fill',
          quality: 'auto',
          format: 'auto',
        });
      }

      const media = await this.prisma.media.create({
        data: {
          url: result.secure_url,
          thumbnailUrl,
          publicId: result.public_id,
          mediaType: mediaType as any,
          category: options.category,
          altText: options.altText,
          title: options.title,
          fileName: result.original_filename || 'uploaded_file',
          fileSize: result.bytes,
          mimeType: `${result.resource_type}/${result.format}`,
          width: result.width,
          height: result.height,
          storageProvider: account.name,
          uploadedBy: userId,
        },
      });

      return {
        id: media.id,
        url: media.url,
        thumbnailUrl: media.thumbnailUrl,
        type: media.mediaType,
        fileName: media.fileName,
        fileSize: media.fileSize,
        storageProvider: media.storageProvider,
      };
    } catch (error) {
      this.logger.error('Upload from URL failed', error);
      throw new BadRequestException('Failed to upload from URL: ' + error.message);
    }
  }

  async findOne(id: string) {
    const media = await this.prisma.media.findUnique({
      where: { id },
    });

    if (!media) throw new NotFoundException('Media not found');
    return media;
  }

  async findByUser(userId: string, params: { page?: number; limit?: number; type?: string; category?: string }) {
    const { page = 1, limit = 20, type, category } = params;
    const skip = (page - 1) * limit;

    const where: any = {
      uploadedBy: userId,
      ...(type && { mediaType: type }),
      ...(category && { category }),
    };

    const [media, total] = await Promise.all([
      this.prisma.media.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.media.count({ where }),
    ]);

    return { data: media, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async update(id: string, userId: string, data: { altText?: string; title?: string; category?: string }) {
    const media = await this.prisma.media.findUnique({ where: { id } });

    if (!media) throw new NotFoundException('Media not found');
    if (media.uploadedBy !== userId) throw new BadRequestException('Not authorized');

    return this.prisma.media.update({
      where: { id },
      data,
    });
  }

  async delete(id: string, userId: string) {
    const media = await this.prisma.media.findUnique({ where: { id } });

    if (!media) throw new NotFoundException('Media not found');
    if (media.uploadedBy !== userId) throw new BadRequestException('Not authorized');

    // Delete from Cloudinary
    if (media.publicId && media.storageProvider) {
      const account = this.accounts.find(a => a.name === media.storageProvider);
      if (account) {
        this.configureCloudinary(account);
        try {
          await cloudinary.uploader.destroy(media.publicId);
        } catch (error) {
          this.logger.warn(`Failed to delete from Cloudinary: ${error.message}`);
        }
      }
    }

    // Delete from database
    await this.prisma.media.delete({ where: { id } });

    return { success: true };
  }

  // Get optimized/transformed URL
  getTransformedUrl(publicId: string, options: {
    width?: number;
    height?: number;
    crop?: string;
    quality?: string;
    format?: string;
  }) {
    return cloudinary.url(publicId, {
      width: options.width,
      height: options.height,
      crop: options.crop || 'fill',
      quality: options.quality || 'auto',
      format: options.format || 'auto',
      secure: true,
    });
  }
}

