import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkAccount(identifier: string) {
  console.log(`🔍 Checking account in database: ${identifier}\n`);

  try {
    // Direct SQL query to check by phone number
    const phoneQuery = await prisma.$queryRaw<Array<{
      id: string;
      email: string | null;
      phone_number: string | null;
      username: string | null;
      full_name: string | null;
      roles: string[];
      is_active: boolean;
      is_verified: boolean;
      created_at: Date;
      last_login_at: Date | null;
    }>>`
      SELECT 
        id,
        email,
        phone_number,
        username,
        full_name,
        roles,
        is_active,
        is_verified,
        created_at,
        last_login_at
      FROM users
      WHERE phone_number = ${identifier}
      LIMIT 1
    `;

    // Direct SQL query to check by email
    const emailQuery = await prisma.$queryRaw<Array<{
      id: string;
      email: string | null;
      phone_number: string | null;
      username: string | null;
      full_name: string | null;
      roles: string[];
      is_active: boolean;
      is_verified: boolean;
      created_at: Date;
      last_login_at: Date | null;
    }>>`
      SELECT 
        id,
        email,
        phone_number,
        username,
        full_name,
        roles,
        is_active,
        is_verified,
        created_at,
        last_login_at
      FROM users
      WHERE email = ${identifier}
      LIMIT 1
    `;

    // Direct SQL query to check by username
    const usernameQuery = await prisma.$queryRaw<Array<{
      id: string;
      email: string | null;
      phone_number: string | null;
      username: string | null;
      full_name: string | null;
      roles: string[];
      is_active: boolean;
      is_verified: boolean;
      created_at: Date;
      last_login_at: Date | null;
    }>>`
      SELECT 
        id,
        email,
        phone_number,
        username,
        full_name,
        roles,
        is_active,
        is_verified,
        created_at,
        last_login_at
      FROM users
      WHERE username = ${identifier}
      LIMIT 1
    `;

    // Direct SQL query to check by ID (UUID)
    let idQuery: typeof phoneQuery = [];
    try {
      idQuery = await prisma.$queryRaw<typeof phoneQuery>`
        SELECT 
          id,
          email,
          phone_number,
          username,
          full_name,
          roles,
          is_active,
          is_verified,
          created_at,
          last_login_at
        FROM users
        WHERE id = ${identifier}::uuid
        LIMIT 1
      `;
    } catch (e) {
      // Not a valid UUID, skip
    }

    const user = phoneQuery[0] || emailQuery[0] || usernameQuery[0] || idQuery[0];

    if (user) {
      console.log('✅ Account found in database!\n');
      console.log('Account Details:');
      console.log(`   ID: ${user.id}`);
      console.log(`   Email: ${user.email || 'N/A'}`);
      console.log(`   Phone: ${user.phone_number || 'N/A'}`);
      console.log(`   Username: ${user.username || 'N/A'}`);
      console.log(`   Full Name: ${user.full_name || 'N/A'}`);
      console.log(`   Roles: ${JSON.stringify(user.roles)}`);
      console.log(`   Active: ${user.is_active}`);
      console.log(`   Verified: ${user.is_verified}`);
      console.log(`   Created: ${user.created_at}`);
      console.log(`   Last Login: ${user.last_login_at || 'Never'}`);
    } else {
      console.log('❌ Account not found in database');
      console.log(`   Searched by: phone number, email, username, and ID`);
      
      // Show count of total users for reference
      const countResult = await prisma.$queryRaw<Array<{ count: bigint }>>`
        SELECT COUNT(*) as count FROM users
      `;
      console.log(`\n   Total users in database: ${countResult[0]?.count || 0}`);
    }
  } catch (error) {
    console.error('❌ Error querying database:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

const identifier = process.argv[2];
if (!identifier) {
  console.error('Usage: ts-node check-account-db.ts <phone|email|username|id>');
  process.exit(1);
}

checkAccount(identifier)
  .catch((error) => {
    console.error('Error:', error);
    process.exit(1);
  });

