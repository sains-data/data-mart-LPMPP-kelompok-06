USE DM_LPMPP_DW;
GO
-- 1. Membuat Login untuk Rektor (Viewer)
CREATE LOGIN [User_Rektor] WITH PASSWORD=N'YourStrongPasswordHere', DEFAULT_DATABASE=[DM_LPMPP_DW];
CREATE USER [User_Rektor] FOR LOGIN [User_Rektor];
-- Kasih hak akses HANYA BISA BACA (Reader)
ALTER ROLE [db_datareader] ADD MEMBER [User_Rektor];

-- 2. Membuat Login untuk Admin IT (Full Akses)
CREATE LOGIN [User_Admin] WITH PASSWORD=N'AdminStrong!', DEFAULT_DATABASE=[DM_LPMPP_DW];
CREATE USER [User_Admin] FOR LOGIN [User_Admin];
-- Memberi hak akses FULL (Owner)
ALTER ROLE [db_owner] ADD MEMBER [User_Admin];
GO