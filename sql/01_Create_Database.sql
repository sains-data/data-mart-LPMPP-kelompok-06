/*
===========================================================================
FILE          : 01_Create_Database.sql
DESCRIPTION   : Script untuk membuat database Data Mart LPMPP (HAKI)
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE master;
GO

-- 1. Cek apakah database sudah ada. Jika ada, hapus dulu untuk reset.
-- DROP DATABASE IF EXISTS DM_LPMPP_DW; -- Syntax modern (SQL 2016+)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DM_LPMPP_DW')
BEGIN
    PRINT 'Database lama ditemukan. Menghapus database...';
    DROP DATABASE DM_LPMPP_DW;
END
GO

PRINT 'Membuat Database DM_LPMPP_DW...';

-- 2. Membuat Database Baru dengan konfigurasi file fisik
-- CATATAN: Sesuaikan path 'FILENAME' dengan struktur folder di laptop/server Anda.
CREATE DATABASE DM_LPMPP_DW
ON PRIMARY
(
    NAME = N'DM_LPMPP_DW_Data',
    FILENAME = N'C:\DataWarehouse\DM_LPMPP_DW_Data.mdf', -- GANTI PATH INI JIKA PERLU
    SIZE = 1GB,             -- Ukuran awal file data
    MAXSIZE = UNLIMITED,    -- Tidak ada batas maksimal
    FILEGROWTH = 256MB      -- Penambahan ukuran otomatis
)
LOG ON
(
    NAME = N'DM_LPMPP_DW_Log',
    FILENAME = N'C:\DataWarehouse\DM_LPMPP_DW_Log.ldf',  -- GANTI PATH INI JIKA PERLU
    SIZE = 256MB,           -- Ukuran awal file log
    MAXSIZE = 2GB,          -- Batas maksimal log 2GB
    FILEGROWTH = 64MB       -- Penambahan log otomatis
);
GO

-- 3. Verifikasi pembuatan database
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DM_LPMPP_DW')
    PRINT 'Database DM_LPMPP_DW berhasil dibuat.';
ELSE
    PRINT 'GAGAL membuat database.';
GO