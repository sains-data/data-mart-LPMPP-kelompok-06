/*
===========================================================================
FILE          : 06_Create_Staging.sql
DESCRIPTION   : Membuat schema dan tabel Staging sebagai area awal proses ETL
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE DM_LPMPP_DW;
GO

PRINT '=== Memulai Pembuatan Staging Area ===';

-- 1. Membuat schema "stg" jika belum tersedia
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO

-- 2. Tabel Staging untuk Fact_PengajuanKI (berdasarkan file Fact_PengajuanKI.csv)
IF OBJECT_ID('stg.Fact_PengajuanKI', 'U') IS NOT NULL DROP TABLE stg.Fact_PengajuanKI;
CREATE TABLE stg.Fact_PengajuanKI (
    PengajuanKey VARCHAR(50),          -- Menggunakan VARCHAR untuk menjamin kompatibilitas saat proses import CSV
    DateKey_Daftar VARCHAR(50),
    DateKey_Granted VARCHAR(50),
    DateKey_Kadaluwarsa VARCHAR(50),
    JenisKIKey VARCHAR(50),
    StatusKey VARCHAR(50),
    JumlahPengajuan VARCHAR(50),
    BiayaPendaftaran VARCHAR(50),
    JumlahPaten VARCHAR(50),
    JumlahPatenSederhana VARCHAR(50),
    JumlahHakCipta VARCHAR(50)
);

-- 3. Tabel Staging untuk Bridge_Pengajuan_Inventor (berdasarkan file Bridge_Pengajuan_Inventor.csv)
IF OBJECT_ID('stg.Bridge_Pengajuan_Inventor', 'U') IS NOT NULL DROP TABLE stg.Bridge_Pengajuan_Inventor;
CREATE TABLE stg.Bridge_Pengajuan_Inventor (
    PengajuanKey VARCHAR(50),
    InventorKey VARCHAR(50),
    Peran_Inventor VARCHAR(100)
);

-- 4. Tabel Staging untuk Dim_Inventor (berdasarkan file Dim_Inventor.csv)
IF OBJECT_ID('stg.Dim_Inventor', 'U') IS NOT NULL DROP TABLE stg.Dim_Inventor;
CREATE TABLE stg.Dim_Inventor (
    InventorKey VARCHAR(50),
    NIP_NIM VARCHAR(50),
    Nama_Inventor VARCHAR(100),
    Nama_Prodi VARCHAR(100),
    Nama_Fakultas VARCHAR(100)
);

-- 5. Tabel Staging untuk Dim_JenisKI (berdasarkan file Dim_JenisKI.csv)
IF OBJECT_ID('stg.Dim_JenisKI', 'U') IS NOT NULL DROP TABLE stg.Dim_JenisKI;
CREATE TABLE stg.Dim_JenisKI (
    JenisKIKey VARCHAR(50),
    Nama_JenisKI VARCHAR(100)
);

-- 6. Tabel Staging untuk Dim_Status (berdasarkan file Dim_Status.csv)
IF OBJECT_ID('stg.Dim_Status', 'U') IS NOT NULL DROP TABLE stg.Dim_Status;
CREATE TABLE stg.Dim_Status (
    StatusKey VARCHAR(50),
    Nama_Status VARCHAR(100)
);

-- 7. Tabel Staging untuk Dim_Date (berdasarkan file Dim_Date.csv)
IF OBJECT_ID('stg.Dim_Date', 'U') IS NOT NULL DROP TABLE stg.Dim_Date;
CREATE TABLE stg.Dim_Date (
    DateKey VARCHAR(50),
    FullDate VARCHAR(50),
    MonthName VARCHAR(50),
    Quarter VARCHAR(50),
    Year VARCHAR(50)
);

PRINT 'Seluruh tabel staging berhasil dibuat.';
GO