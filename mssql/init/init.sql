-- Tạo database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'car_retail')
BEGIN
    CREATE DATABASE car_retail COLLATE Latin1_General_100_CI_AS_SC_UTF8;  -- Collation UTF-8;
    PRINT '✅ Database car_retail created';
END
GO

-- Sử dụng database
USE car_retail;
GO

-- Tạo login & user nếu chưa tồn tại
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'dongnt_user')
BEGIN
    CREATE LOGIN dongnt_user WITH PASSWORD = 'DongCopper80!';
    PRINT '✅ Login dongnt_user created';
END
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'dongnt_user')
BEGIN
    CREATE USER dongnt_user FOR LOGIN dongnt_user;
    PRINT '✅ User dongnt_user created in car_retail DB';
END
GO

-- Tạo role nếu chưa tồn tại
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'dongnt_role')
BEGIN
    CREATE ROLE dongnt_role;
    PRINT '✅ Role dongnt_role created';
END
GO

-- Gán quyền cho role
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: dbo TO dongnt_role;
GRANT CREATE TABLE TO dongnt_role;
GO

-- Thêm user vào role
ALTER ROLE dongnt_role ADD MEMBER dongnt_user;
GO

PRINT '🎉 Database, user, role, and permissions have been set up successfully!';
