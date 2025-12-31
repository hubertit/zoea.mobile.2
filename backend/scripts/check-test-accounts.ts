import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkTestAccounts() {
  console.log('🔍 Checking test accounts in database...\n');

  // Check super admin account
  const superAdminEmail = 'hubert@zoea.africa';
  const superAdminPhone = '250788606765';

  console.log('1. Checking Super Admin Account:');
  console.log(`   Email: ${superAdminEmail}`);
  console.log(`   Phone: ${superAdminPhone}\n`);

  const userByEmail = await prisma.user.findUnique({
    where: { email: superAdminEmail },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      roles: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
    },
  });

  const userByPhone = await prisma.user.findUnique({
    where: { phoneNumber: superAdminPhone },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      roles: true,
      isActive: true,
      isVerified: true,
      createdAt: true,
    },
  });

  if (userByEmail) {
    console.log('   ✅ Found by email:');
    console.log(`      ID: ${userByEmail.id}`);
    console.log(`      Name: ${userByEmail.fullName || 'N/A'}`);
    console.log(`      Roles: ${JSON.stringify(userByEmail.roles)}`);
    console.log(`      Active: ${userByEmail.isActive}`);
    console.log(`      Verified: ${userByEmail.isVerified}`);
    console.log(`      Created: ${userByEmail.createdAt}`);
  } else {
    console.log('   ❌ Not found by email');
  }

  if (userByPhone) {
    console.log('   ✅ Found by phone:');
    console.log(`      ID: ${userByPhone.id}`);
    console.log(`      Name: ${userByPhone.fullName || 'N/A'}`);
    console.log(`      Roles: ${JSON.stringify(userByPhone.roles)}`);
    console.log(`      Active: ${userByPhone.isActive}`);
    console.log(`      Verified: ${userByPhone.isVerified}`);
    console.log(`      Created: ${userByPhone.createdAt}`);
  } else {
    console.log('   ❌ Not found by phone');
  }

  // Check for test merchant accounts
  console.log('\n2. Checking for Merchant Accounts:');
  const merchantUsers = await prisma.user.findMany({
    where: {
      roles: {
        has: 'MERCHANT',
      },
    },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      roles: true,
      isActive: true,
      createdAt: true,
    },
    take: 10,
  });

  if (merchantUsers.length > 0) {
    console.log(`   ✅ Found ${merchantUsers.length} merchant account(s):`);
    merchantUsers.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.fullName || 'N/A'}`);
      console.log(`      Email: ${user.email || 'N/A'}`);
      console.log(`      Phone: ${user.phoneNumber || 'N/A'}`);
      console.log(`      Roles: ${JSON.stringify(user.roles)}`);
      console.log(`      Active: ${user.isActive}`);
      console.log(`      Created: ${user.createdAt}`);
      console.log('');
    });
  } else {
    console.log('   ❌ No merchant accounts found');
  }

  // Check for test accounts
  console.log('\n3. Checking for Test Accounts (email contains "test"):');
  const testUsers = await prisma.user.findMany({
    where: {
      OR: [
        { email: { contains: 'test', mode: 'insensitive' } },
        { email: { contains: 'demo', mode: 'insensitive' } },
      ],
    },
    select: {
      id: true,
      email: true,
      phoneNumber: true,
      fullName: true,
      roles: true,
      isActive: true,
      createdAt: true,
    },
    take: 10,
  });

  if (testUsers.length > 0) {
    console.log(`   ✅ Found ${testUsers.length} test account(s):`);
    testUsers.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.fullName || 'N/A'}`);
      console.log(`      Email: ${user.email || 'N/A'}`);
      console.log(`      Phone: ${user.phoneNumber || 'N/A'}`);
      console.log(`      Roles: ${JSON.stringify(user.roles)}`);
      console.log(`      Active: ${user.isActive}`);
      console.log(`      Created: ${user.createdAt}`);
      console.log('');
    });
  } else {
    console.log('   ❌ No test accounts found');
  }

  await prisma.$disconnect();
}

checkTestAccounts()
  .catch((error) => {
    console.error('Error checking accounts:', error);
    process.exit(1);
  });

