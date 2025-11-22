/*
===========================================================================
FILE          : 03_Create_Facts.sql
DESCRIPTION   : Script DDL untuk membuat tabel Fakta dan Bridge pada Data Warehouse
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
DEPENDENCIES  : Tabel dimensi harus sudah dibuat (jalankan script 05 terlebih dahulu)
CREATED DATE  : 2025-11-20
DBMS          : SQL Server 2019 / Azure SQL
===========================================================================
*/

USE DM_LPMPP_DW;
GO

PRINT '=== Memulai Pembuatan Tabel Fakta ===';

-- Menghapus tabel jika sudah ada sebelumnya
IF OBJECT_ID('dbo.Bridge_Pengajuan_Inventor', 'U') IS NOT NULL DROP TABLE dbo.Bridge_Pengajuan_Inventor;
IF OBJECT_ID('dbo.Fact_PengajuanKI', 'U') IS NOT NULL DROP TABLE dbo.Fact_PengajuanKI;
GO

------------------------------
-- FACT TABLE
------------------------------
CREATE TABLE dbo.Fact_PengajuanKI (
    PengajuanKey INT NOT NULL,

    DateKey_Daftar INT NOT NULL,
    DateKey_Granted INT NULL,
    DateKey_Kadaluwarsa INT NULL,
    JenisKIKey INT NOT NULL,
    StatusKey INT NOT NULL,

    JumlahPengajuan INT DEFAULT 1,
    BiayaPendaftaran DECIMAL(18,2),
    JumlahPaten INT DEFAULT 0,
    JumlahPatenSederhana INT DEFAULT 0,
    JumlahHakCipta INT DEFAULT 0,

    LoadDate DATETIME DEFAULT GETDATE(),

    -- Primary Key nonclustered sekaligus kolom partisi
    CONSTRAINT PK_Fact_PengajuanKI 
        PRIMARY KEY NONCLUSTERED (DateKey_Daftar, PengajuanKey),

    -- Foreign Key ke tabel dimensi
    CONSTRAINT FK_Fact_DateDaftar FOREIGN KEY (DateKey_Daftar) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_DateGranted FOREIGN KEY (DateKey_Granted) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_DateKadaluwarsa FOREIGN KEY (DateKey_Kadaluwarsa) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_JenisKI FOREIGN KEY (JenisKIKey) REFERENCES dbo.Dim_JenisKI(JenisKIKey),
    CONSTRAINT FK_Fact_Status FOREIGN KEY (StatusKey) REFERENCES dbo.Dim_Status(StatusKey)
)
ON PS_TahunPengajuan(DateKey_Daftar);
GO

PRINT 'Tabel Fact_PengajuanKI berhasil dibuat dan dipartisi.';

------------------------------
-- UNIQUE INDEX NONPARTITIONED
------------------------------
CREATE UNIQUE NONCLUSTERED INDEX IXU_Fact_PengajuanKey
ON dbo.Fact_PengajuanKI(PengajuanKey)
ON [PRIMARY];
GO

------------------------------
-- BRIDGE TABLE
------------------------------
CREATE TABLE dbo.Bridge_Pengajuan_Inventor (
    PengajuanKey INT NOT NULL,
    InventorKey INT NOT NULL,
    Peran_Inventor VARCHAR(100),

    CONSTRAINT PK_Bridge_Pengajuan_Inventor 
        PRIMARY KEY (PengajuanKey, InventorKey),

    CONSTRAINT FK_Bridge_Pengajuan 
        FOREIGN KEY (PengajuanKey) REFERENCES dbo.Fact_PengajuanKI(PengajuanKey),

    CONSTRAINT FK_Bridge_Inventor 
        FOREIGN KEY (InventorKey) REFERENCES dbo.Dim_Inventor(InventorKey)
);
GO

PRINT 'Tabel Bridge_Pengajuan_Inventor berhasil dibuat.';
PRINT '=== Seluruh Tabel Berhasil Dibuat ===';
GO