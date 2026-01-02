import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkAccount(identifier: string) {
  console.log(`🔍 Checking account: ${identifier}\n`);

  // Try to find by phone number
  const userByPhone = await prisma.user.findUnique({
    where: { phoneNumber: identifier },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      username: true,
      roles: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
      lastLoginAt: true,
    },
  });

  // Try to find by email
  const userByEmail = await prisma.user.findUnique({
    where: { email: identifier },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      username: true,
      roles: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
      lastLoginAt: true,
    },
  });

  // Try to find by username
  const userByUsername = await prisma.user.findUnique({
    where: { username: identifier },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      username: true,
      roles: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
      lastLoginAt: true,
    },
  });

  // Try to find by ID (UUID)
  let userById = null;
  try {
    userById = await prisma.user.findUnique({
      where: { id: identifier },
      select: {
        id: true,
        email: true,
        phoneNumber: true,
        fullName: true,
        username: true,
        roles: true,
        isActive: true,
        isVerified: true,
        createdAt: true,
        lastLoginAt: true,
      },
    });
  } catch (e) {
    // Not a valid UUID, skip
  }

  const user = userByPhone || userByEmail || userByUsername || userById;

  if (user) {
    console.log('✅ Account found!\n');
    console.log('Account Details:');
    console.log(`   ID: ${user.id}`);
    console.log(`   Email: ${user.email || 'N/A'}`);
    console.log(`   Phone: ${user.phoneNumber || 'N/A'}`);
    console.log(`   Username: ${user.username || 'N/A'}`);
    console.log(`   Full Name: ${user.fullName || 'N/A'}`);
    console.log(`   Roles: ${JSON.stringify(user.roles)}`);
    console.log(`   Active: ${user.isActive}`);
    console.log(`   Verified: ${user.isVerified}`);
    console.log(`   Created: ${user.createdAt}`);
    console.log(`   Last Login: ${user.lastLoginAt || 'Never'}`);
  } else {
    console.log('❌ Account not found');
    console.log(`   Searched by: phone number, email, username, and ID`);
  }

  await prisma.$disconnect();
}

const identifier = process.argv[2];
if (!identifier) {
  console.error('Usage: ts-node check-account.ts <phone|email|username|id>');
  process.exit(1);
}

checkAccount(identifier)
  .catch((error) => {
    console.error('Error checking account:', error);
    process.exit(1);
  });

