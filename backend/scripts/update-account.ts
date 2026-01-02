import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function updateAccount(oldPhone: string, newPhone: string, newPassword: string) {
  console.log(`🔧 Updating account...\n`);
  console.log(`   Old Phone: ${oldPhone}`);
  console.log(`   New Phone: ${newPhone}`);
  console.log(`   New Password: ${newPassword}\n`);

  try {
    // First, check if the account exists
    const existingUser = await prisma.$queryRaw<Array<{
      id: string;
      email: string | null;
      phone_number: string | null;
      full_name: string | null;
    }>>`
      SELECT id, email, phone_number, full_name
      FROM users
      WHERE phone_number = ${oldPhone}
      LIMIT 1
    `;

    if (existingUser.length === 0) {
      console.log(`❌ Account with phone number ${oldPhone} not found`);
      await prisma.$disconnect();
      process.exit(1);
    }

    const user = existingUser[0];
    console.log(`✅ Found account:`);
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email || 'N/A'}`);
    console.log(`   Name: ${user.full_name || 'N/A'}\n`);

    // Check if new phone number already exists
    const phoneCheck = await prisma.$queryRaw<Array<{ id: string }>>`
      SELECT id
      FROM users
      WHERE phone_number = ${newPhone}
      AND id != ${user.id}::uuid
      LIMIT 1
    `;

    if (phoneCheck.length > 0) {
      console.log(`❌ Phone number ${newPhone} is already in use by another account`);
      await prisma.$disconnect();
      process.exit(1);
    }

    // Hash the new password
    console.log(`🔐 Hashing password...`);
    const passwordHash = await bcrypt.hash(newPassword, 10);

    // Update phone number and password using direct SQL
    console.log(`📝 Updating account in database...`);
    await prisma.$executeRaw`
      UPDATE users
      SET 
        phone_number = ${newPhone},
        password_hash = ${passwordHash},
        updated_at = NOW()
      WHERE id = ${user.id}::uuid
    `;

    // Verify the update
    const updatedUser = await prisma.$queryRaw<Array<{
      id: string;
      email: string | null;
      phone_number: string | null;
      full_name: string | null;
      is_active: boolean;
      is_verified: boolean;
    }>>`
      SELECT id, email, phone_number, full_name, is_active, is_verified
      FROM users
      WHERE id = ${user.id}::uuid
      LIMIT 1
    `;

    if (updatedUser.length > 0) {
      const updated = updatedUser[0];
      console.log(`\n✅ Account updated successfully!\n`);
      console.log(`Updated Account Details:`);
      console.log(`   ID: ${updated.id}`);
      console.log(`   Email: ${updated.email || 'N/A'}`);
      console.log(`   Phone: ${updated.phone_number}`);
      console.log(`   Name: ${updated.full_name || 'N/A'}`);
      console.log(`   Active: ${updated.is_active}`);
      console.log(`   Verified: ${updated.is_verified}`);
      console.log(`\n✅ Password has been set to: ${newPassword}`);
    } else {
      console.log(`❌ Failed to verify update`);
    }
  } catch (error) {
    console.error('❌ Error updating account:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Get arguments from command line
const oldPhone = process.argv[2];
const newPhone = process.argv[3];
const newPassword = process.argv[4] || 'Pass123';

if (!oldPhone || !newPhone) {
  console.error('Usage: ts-node update-account.ts <old_phone> <new_phone> [password]');
  console.error('Example: ts-node update-account.ts 250250786375245 250786375245 Pass123');
  process.exit(1);
}

updateAccount(oldPhone, newPhone, newPassword)
  .catch((error) => {
    console.error('Error:', error);
    process.exit(1);
  });

