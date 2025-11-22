/*
===========================================================================
FILE          : 08_Data_Quality_Checks.sql
DESCRIPTION   : Script untuk melakukan pengecekan kualitas data (DQA)
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

/* ==================================================
   DQA 1: Completeness Check (Row Count Comparison)
   Memeriksa kesesuaian jumlah baris antara tabel Staging dan Fact
   ================================================== */
SELECT 
    'Staging Area' AS Source_System, 
    COUNT(*) AS Total_Rows 
FROM stg.Fact_PengajuanKI
UNION ALL
SELECT 
    'Data Warehouse (Fact)', 
    COUNT(*) 
FROM dbo.Fact_PengajuanKI;

/* ==================================================
   DQA 2: Consistency Check (Null Values in Mandatory Columns)
   Mengidentifikasi baris yang memiliki nilai NULL pada kolom wajib
   ================================================== */
SELECT 
    COUNT(*) AS Total_Violations
FROM dbo.Fact_PengajuanKI
WHERE 
    PengajuanKey IS NULL 
    OR StatusKey IS NULL 
    OR JenisKIKey IS NULL 
    OR DateKey_Daftar IS NULL;

/* ==================================================
   DQA 3: Validity Check (Business Rule Validation)
   Memverifikasi bahwa tidak ada nilai negatif pada kolom numerik utama
   ================================================== */
SELECT 
    COUNT(*) AS Invalid_Data_Count
FROM dbo.Fact_PengajuanKI
WHERE 
    BiayaPendaftaran < 0
    OR JumlahPengajuan < 0;

/* ==================================================
   DQA 4: Referential Integrity Check (Orphaned Records)
   Memastikan seluruh Foreign Key pada tabel Fact memiliki pasangan di tabel Dimensi
   ================================================== */
SELECT 
    f.PengajuanKey, 
    f.StatusKey
FROM dbo.Fact_PengajuanKI f
LEFT JOIN dbo.Dim_Status s ON f.StatusKey = s.StatusKey
WHERE s.StatusKey IS NULL;