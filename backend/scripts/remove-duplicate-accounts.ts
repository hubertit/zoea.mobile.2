import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface DuplicateAccount {
  id: string;
  phone_number: string | null;
  email: string | null;
  full_name: string | null;
  created_at: Date;
  has_email: boolean;
  has_name: boolean;
  completeness_score: number;
}

async function findDuplicates(phonePattern: string): Promise<DuplicateAccount[]> {
  // Find all accounts with similar phone numbers
  const accounts = await prisma.$queryRaw<Array<{
    id: string;
    phone_number: string | null;
    email: string | null;
    full_name: string | null;
    created_at: Date;
  }>>`
    SELECT 
      id,
      phone_number,
      email,
      full_name,
      created_at
    FROM users
    WHERE phone_number LIKE ${`%${phonePattern}%`}
       OR phone_number LIKE ${`%${phonePattern.replace('250', '')}%`}
    ORDER BY created_at ASC
  `;

  // Calculate completeness score for each account
  const accountsWithScore: DuplicateAccount[] = accounts.map(acc => {
    const has_email = !!acc.email;
    const has_name = !!acc.full_name;
    const completeness_score = (has_email ? 10 : 0) + (has_name ? 5 : 0) + (acc.created_at ? 1 : 0);
    
    return {
      ...acc,
      has_email,
      has_name,
      completeness_score,
    };
  });

  return accountsWithScore.sort((a, b) => b.completeness_score - a.completeness_score);
}

async function checkRelatedData(userId: string): Promise<{
  bookings: number;
  orders: number;
  reviews: number;
  sessions: number;
  favorites: number;
  carts: number;
  transactions: number;
  merchantProfiles: number;
  organizerProfiles: number;
  tourOperatorProfiles: number;
}> {
  const [bookings, orders, reviews, sessions, favorites, carts, transactions, merchantProfiles, organizerProfiles, tourOperatorProfiles] = await Promise.all([
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM bookings WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM orders WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM reviews WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM user_sessions WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM favorites WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM carts WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM transactions WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM merchant_profiles WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM organizer_profiles WHERE user_id = ${userId}::uuid`,
    prisma.$queryRaw<Array<{ count: bigint }>>`SELECT COUNT(*) as count FROM tour_operator_profiles WHERE user_id = ${userId}::uuid`,
  ]);

  return {
    bookings: Number(bookings[0]?.count || 0),
    orders: Number(orders[0]?.count || 0),
    reviews: Number(reviews[0]?.count || 0),
    sessions: Number(sessions[0]?.count || 0),
    favorites: Number(favorites[0]?.count || 0),
    carts: Number(carts[0]?.count || 0),
    transactions: Number(transactions[0]?.count || 0),
    merchantProfiles: Number(merchantProfiles[0]?.count || 0),
    organizerProfiles: Number(organizerProfiles[0]?.count || 0),
    tourOperatorProfiles: Number(tourOperatorProfiles[0]?.count || 0),
  };
}

async function deleteUserSafely(userId: string): Promise<void> {
  console.log(`\n🗑️  Deleting user ${userId}...`);

  // Delete related data in order (respecting foreign key constraints)
  // Start with data that has CASCADE or can be safely deleted
  
  // Delete carts (has CASCADE)
  await prisma.$executeRaw`DELETE FROM carts WHERE user_id = ${userId}::uuid`;
  
  // Delete user sessions
  await prisma.$executeRaw`DELETE FROM user_sessions WHERE user_id = ${userId}::uuid`;
  
  // Delete favorites
  await prisma.$executeRaw`DELETE FROM favorites WHERE user_id = ${userId}::uuid`;
  
  // Delete reviews (if any)
  await prisma.$executeRaw`DELETE FROM reviews WHERE user_id = ${userId}::uuid`;
  
  // Delete bookings (may have related data, but we'll delete)
  await prisma.$executeRaw`DELETE FROM booking_guests WHERE booking_id IN (SELECT id FROM bookings WHERE user_id = ${userId}::uuid)`;
  await prisma.$executeRaw`DELETE FROM bookings WHERE user_id = ${userId}::uuid`;
  
  // Delete orders (may have related data)
  await prisma.$executeRaw`DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = ${userId}::uuid)`;
  await prisma.$executeRaw`DELETE FROM orders WHERE user_id = ${userId}::uuid`;
  
  // Delete transactions
  await prisma.$executeRaw`DELETE FROM transactions WHERE user_id = ${userId}::uuid`;
  
  // Delete profiles
  await prisma.$executeRaw`DELETE FROM merchant_profiles WHERE user_id = ${userId}::uuid`;
  await prisma.$executeRaw`DELETE FROM organizer_profiles WHERE user_id = ${userId}::uuid`;
  await prisma.$executeRaw`DELETE FROM tour_operator_profiles WHERE user_id = ${userId}::uuid`;
  
  // Delete zoea cards
  await prisma.$executeRaw`DELETE FROM zoea_cards WHERE user_id = ${userId}::uuid`;
  
  // Finally, delete the user
  await prisma.$executeRaw`DELETE FROM users WHERE id = ${userId}::uuid`;
  
  console.log(`   ✅ User deleted successfully`);
}

async function removeDuplicates(phonePattern: string, dryRun: boolean = true) {
  console.log(`🔍 Finding duplicate accounts for pattern: ${phonePattern}\n`);

  const duplicates = await findDuplicates(phonePattern);

  if (duplicates.length <= 1) {
    console.log(`✅ No duplicates found. Only ${duplicates.length} account(s) with this pattern.`);
    await prisma.$disconnect();
    return;
  }

  console.log(`Found ${duplicates.length} duplicate account(s):\n`);

  // Display all duplicates
  for (let i = 0; i < duplicates.length; i++) {
    const acc = duplicates[i];
    const relatedData = await checkRelatedData(acc.id);
    const totalRelated = Object.values(relatedData).reduce((sum, val) => sum + val, 0);

    console.log(`${i + 1}. Account ${acc.id}`);
    console.log(`   Phone: ${acc.phone_number || 'N/A'}`);
    console.log(`   Email: ${acc.email || 'N/A'}`);
    console.log(`   Name: ${acc.full_name || 'N/A'}`);
    console.log(`   Created: ${acc.created_at}`);
    console.log(`   Completeness Score: ${acc.completeness_score}`);
    console.log(`   Related Data: ${totalRelated} items`);
    if (totalRelated > 0) {
      console.log(`     - Bookings: ${relatedData.bookings}`);
      console.log(`     - Orders: ${relatedData.orders}`);
      console.log(`     - Reviews: ${relatedData.reviews}`);
      console.log(`     - Sessions: ${relatedData.sessions}`);
      console.log(`     - Favorites: ${relatedData.favorites}`);
      console.log(`     - Carts: ${relatedData.carts}`);
      console.log(`     - Transactions: ${relatedData.transactions}`);
    }
    console.log('');
  }

  // The first one (highest score) is the one to keep
  const keepAccount = duplicates[0];
  const deleteAccounts = duplicates.slice(1);

  console.log(`\n📌 Account to KEEP: ${keepAccount.id}`);
  console.log(`   Phone: ${keepAccount.phone_number}`);
  console.log(`   Email: ${keepAccount.email || 'N/A'}`);
  console.log(`   Name: ${keepAccount.full_name || 'N/A'}`);
  console.log(`   Reason: Highest completeness score (${keepAccount.completeness_score})\n`);

  console.log(`🗑️  Accounts to DELETE: ${deleteAccounts.length}`);
  deleteAccounts.forEach((acc, i) => {
    console.log(`   ${i + 1}. ${acc.id} (${acc.phone_number})`);
  });

  if (dryRun) {
    console.log(`\n⚠️  DRY RUN MODE - No changes will be made`);
    console.log(`   Run with --execute flag to actually delete duplicates`);
  } else {
    console.log(`\n⚠️  EXECUTING DELETIONS...`);
    
    for (const acc of deleteAccounts) {
      const relatedData = await checkRelatedData(acc.id);
      const totalRelated = Object.values(relatedData).reduce((sum, val) => sum + val, 0);
      
      if (totalRelated > 0) {
        console.log(`\n⚠️  Warning: Account ${acc.id} has ${totalRelated} related data items`);
        console.log(`   Proceeding with deletion...`);
      }
      
      await deleteUserSafely(acc.id);
    }

    console.log(`\n✅ All duplicate accounts deleted successfully!`);
    console.log(`   Kept account: ${keepAccount.id} (${keepAccount.phone_number})`);
  }

  await prisma.$disconnect();
}

const phonePattern = process.argv[2];
const execute = process.argv.includes('--execute');

if (!phonePattern) {
  console.error('Usage: ts-node remove-duplicate-accounts.ts <phone_pattern> [--execute]');
  console.error('Example: ts-node remove-duplicate-accounts.ts 786375245');
  console.error('Example: ts-node remove-duplicate-accounts.ts 786375245 --execute');
  process.exit(1);
}

removeDuplicates(phonePattern, !execute)
  .catch((error) => {
    console.error('Error:', error);
    process.exit(1);
  });

