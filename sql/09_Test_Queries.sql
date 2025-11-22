/*
===========================================================================
FILE          : 09_Test_Queries.sql
DESCRIPTION   : Script untuk melakukan pengujian performa query pada Data Warehouse
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE DM_LPMPP_DW;
GO

-- 1. Mengaktifkan mode pencatatan waktu dan aktivitas I/O untuk analisis performa
SET STATISTICS TIME ON; -- Menampilkan durasi eksekusi dalam milidetik
SET STATISTICS IO ON;   -- Menampilkan detail pembacaan dan penulisan I/O
GO

PRINT '=== TEST 1: QUERY AGREGASI JOIN (Pengujian Index) ===';
-- Query ini melakukan agregasi dengan operasi JOIN untuk memastikan indeks
-- pada kolom Foreign Key (StatusKey dan JenisKIKey) berfungsi optimal.
-- Dengan indeks yang telah dibuat pada Step 4, query ini seharusnya dieksekusi dengan cepat.

SELECT 
    j.Nama_JenisKI,
    s.Nama_Status,
    SUM(f.JumlahPengajuan) AS Total_Pengajuan,
    SUM(f.BiayaPendaftaran) AS Total_Biaya
FROM dbo.Fact_PengajuanKI f
JOIN dbo.Dim_JenisKI j ON f.JenisKIKey = j.JenisKIKey
JOIN dbo.Dim_Status s ON f.StatusKey = s.StatusKey
GROUP BY j.Nama_JenisKI, s.Nama_Status
ORDER BY Total_Pengajuan DESC;
GO

PRINT '=== TEST 2: QUERY FILTER PARTISI (Pengujian Partition Pruning) ===';
-- Query ini memfokuskan filter pada data tahun 2024.
-- Karena tabel Fact telah dipartisi berdasarkan tahun (Step 5), SQL Server
-- hanya akan membaca partisi yang relevan (2024) tanpa melakukan pemindaian
-- terhadap partisi tahun lainnya, sehingga meningkatkan efisiensi.

SELECT 
    DateKey_Daftar,
    COUNT(PengajuanKey) AS Jumlah_Harian
FROM dbo.Fact_PengajuanKI
WHERE DateKey_Daftar BETWEEN 20240101 AND 20241231 -- Filter untuk satu tahun
GROUP BY DateKey_Daftar
ORDER BY DateKey_Daftar;
GO

-- Menonaktifkan mode statistik setelah pengujian selesai
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
