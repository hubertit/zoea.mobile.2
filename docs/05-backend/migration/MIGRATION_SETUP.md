# V1 Database Setup for Migration

## Option 1: Import SQL Dump to Local MySQL (Recommended)

If you want to run the migration locally, you need to:

1. **Install MySQL/MariaDB** (if not already installed):
   ```bash
   brew install mysql
   # OR
   brew install mariadb
   ```

2. **Start MySQL service**:
   ```bash
   brew services start mysql
   # OR
   brew services start mariadb
   ```

3. **Create database**:
   ```bash
   mysql -u root -p -e "CREATE DATABASE devsvknl_tarama;"
   ```

4. **Import the SQL dump**:
   ```bash
   mysql -u root -p devsvknl_tarama < "/Applications/AMPPS/www/zoea-2/database/zoea v1.sql"
   ```

5. **Update .env file**:
   ```env
   V1_DB_HOST=localhost
   V1_DB_PORT=3306
   V1_DB_USER=root
   V1_DB_PASSWORD=your_mysql_root_password
   V1_DB_NAME=devsvknl_tarama
   ```

## Option 2: Connect to Remote V1 Database

If the V1 database is on a remote server:

1. **Update .env file** with remote credentials:
   ```env
   V1_DB_HOST=your_remote_host
   V1_DB_PORT=3306
   V1_DB_USER=your_remote_user
   V1_DB_PASSWORD=your_remote_password
   V1_DB_NAME=devsvknl_tarama
   ```

2. **Ensure network access** to the remote database

## Option 3: Use Docker (Alternative)

If you prefer Docker:

```bash
# Run MySQL in Docker
docker run --name zoea-v1-db \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=devsvknl_tarama \
  -p 3306:3306 \
  -d mysql:8.0

# Import SQL dump
docker exec -i zoea-v1-db mysql -uroot -prootpassword devsvknl_tarama < /Applications/AMPPS/www/zoea-2/ui/db/zoea-1.sql
```

Then use:
```env
V1_DB_HOST=localhost
V1_DB_PORT=3306
V1_DB_USER=root
V1_DB_PASSWORD=rootpassword
V1_DB_NAME=devsvknl_tarama
```

## Recommended Approach

**Option 1 (Local Import)** is recommended because:
- ✅ Faster migration (local connection)
- ✅ No network issues
- ✅ Safe (doesn't affect production V1)
- ✅ Can test migration multiple times

## After Setup

Once the V1 database is accessible, run:
```bash
pnpm migrate
```

