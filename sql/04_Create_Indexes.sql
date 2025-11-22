/*
===========================================================================
FILE          : 04_Create_Indexes.sql
DESCRIPTION   : Membuat index untuk meningkatkan performa query pada Data Warehouse
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE DM_LPMPP_DW;
GO

PRINT '=== Memulai Pembuatan Index ===';

-- 1. Index pada tabel fakta untuk mendukung operasi JOIN berbasis Foreign Key
CREATE NONCLUSTERED INDEX IX_Fact_DateDaftar ON dbo.Fact_PengajuanKI(DateKey_Daftar);
CREATE NONCLUSTERED INDEX IX_Fact_JenisKI ON dbo.Fact_PengajuanKI(JenisKIKey);
CREATE NONCLUSTERED INDEX IX_Fact_Status ON dbo.Fact_PengajuanKI(StatusKey);
CREATE NONCLUSTERED INDEX IX_Fact_InventorBridge ON dbo.Bridge_Pengajuan_Inventor(InventorKey);

PRINT 'Index pada Foreign Key berhasil dibuat.';

-- 2. Index pada tabel dimensi untuk mempercepat proses pencarian
CREATE NONCLUSTERED INDEX IX_Dim_Inventor_NIP ON dbo.Dim_Inventor(NIP_NIM); -- Mempercepat pencarian Inventor
CREATE NONCLUSTERED INDEX IX_Dim_Status_Nama ON dbo.Dim_Status(Nama_Status); -- Mempercepat filter berdasarkan Status

PRINT 'Index pada tabel dimensi berhasil dibuat.';
GO