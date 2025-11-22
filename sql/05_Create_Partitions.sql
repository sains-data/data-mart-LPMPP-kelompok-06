/*
===========================================================================
FILE          : 05_Create_Partitions.sql
DESCRIPTION   : Membuat strategi partisi berdasarkan tahun menggunakan Partition Function dan Scheme
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE DM_LPMPP_DW;
GO

PRINT '=== Memulai Strategi Partisi ===';

-- 1. Membuat Partition Function
-- Partisi dibuat berdasarkan range tahun menggunakan kolom DateKey (format YYYYMMDD)
-- Rentang tahun yang digunakan meliputi 2020 hingga 2024
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'PF_TahunPengajuan')
    DROP PARTITION FUNCTION PF_TahunPengajuan;

CREATE PARTITION FUNCTION PF_TahunPengajuan (INT)
AS RANGE RIGHT FOR VALUES 
(
    20210101, -- Batas data < 2021
    20220101, -- Batas data 2021–2022
    20230101, -- Batas data 2022–2023
    20240101, -- Batas data 2023–2024
    20250101  -- Batas data 2024–2025
);
PRINT 'Partition Function berhasil dibuat.';
GO

-- 2. Membuat Partition Scheme
-- Seluruh partisi diarahkan ke Filegroup PRIMARY untuk penyimpanan standar
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'PS_TahunPengajuan')
    DROP PARTITION SCHEME PS_TahunPengajuan;

CREATE PARTITION SCHEME PS_TahunPengajuan
AS PARTITION PF_TahunPengajuan
ALL TO ([PRIMARY]);

PRINT 'Partition Scheme berhasil dibuat.';
GO