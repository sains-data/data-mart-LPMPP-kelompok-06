/*
===========================================================================
FILE          : 02_Create_Dimensions.sql
DESCRIPTION   : Script DDL untuk membuat Tabel Dimensi (Master Data)
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
DEPENDENCIES  : Database DM_LPMPP_DW harus sudah dibuat (jalankan script 01 dulu)
===========================================================================
*/

USE DM_LPMPP_DW;
GO

PRINT '=== Memulai Pembuatan Tabel Dimensi ===';

-- =============================================
-- 1. Dimensi Jenis KI
-- Deskripsi: Menyimpan jenis-jenis Kekayaan Intelektual (Paten, Hak Cipta, dll)
-- =============================================
IF OBJECT_ID('dbo.Dim_JenisKI', 'U') IS NOT NULL DROP TABLE dbo.Dim_JenisKI;
CREATE TABLE dbo.Dim_JenisKI (
    JenisKIKey INT NOT NULL,        -- Business Key / Surrogate Key
    Nama_JenisKI VARCHAR(50) NOT NULL, -- Label Jenis KI
    
    CONSTRAINT PK_Dim_JenisKI PRIMARY KEY (JenisKIKey)
);
PRINT 'Tabel Dim_JenisKI berhasil dibuat.';
GO

-- =============================================
-- 2. Dimensi Status
-- Deskripsi: Menyimpan status pengajuan (Granted, Submitted, Rejected, dll)
-- =============================================
IF OBJECT_ID('dbo.Dim_Status', 'U') IS NOT NULL DROP TABLE dbo.Dim_Status;
CREATE TABLE dbo.Dim_Status (
    StatusKey INT NOT NULL,
    Nama_Status VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Dim_Status PRIMARY KEY (StatusKey)
);
PRINT 'Tabel Dim_Status berhasil dibuat.';
GO

-- =============================================
-- 3. Dimensi Inventor
-- Deskripsi: Menyimpan data profil pengusul (Dosen/Mahasiswa)
-- =============================================
IF OBJECT_ID('dbo.Dim_Inventor', 'U') IS NOT NULL DROP TABLE dbo.Dim_Inventor;
CREATE TABLE dbo.Dim_Inventor (
    InventorKey INT IDENTITY(1,1) NOT NULL, 
    NIP_NIM VARCHAR(50) NOT NULL UNIQUE,            -- Nomor Induk (Natural Key)
    Nama_Inventor VARCHAR(150),
    Nama_Prodi VARCHAR(100),        -- Informasi hierarki Prodi
    Nama_Fakultas VARCHAR(100),     -- Informasi hierarki Fakultas

    StartDate DATE NOT NULL,        -- Kapan baris ini mulai berlaku
    EndDate DATE NULL,              -- Kapan baris ini berakhir
    IsCurrent BIT NOT NULL,         -- Flag: 1 jika masih aktif, 0 jika sudah kadaluwarsa
    
    CONSTRAINT PK_Dim_Inventor PRIMARY KEY (InventorKey)
);
PRINT 'Tabel Dim_Inventor berhasil dibuat.';
GO

-- =============================================
-- 4. Dimensi Date
-- Deskripsi: Dimensi waktu untuk analisis periode (Wajib ada di DW)
-- =============================================
IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL DROP TABLE dbo.Dim_Date;
CREATE TABLE dbo.Dim_Date (
    DateKey INT NOT NULL,           -- Format integer: YYYYMMDD (cth: 20250101)
    FullDate DATE NOT NULL,         -- Format date SQL
    MonthName VARCHAR(20) NOT NULL, -- Nama Bulan (Januari, dst)
    Quarter VARCHAR(2) NOT NULL,   -- Kuartal (Q1, Q2, dst)
    Year INT NOT NULL,              -- Tahun (2025, dst)
    
    CONSTRAINT PK_Dim_Date PRIMARY KEY (DateKey)
);
PRINT 'Tabel Dim_Date berhasil dibuat.';
GO