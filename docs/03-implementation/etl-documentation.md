# ETL Implementation Documentation

**Project:** Data Mart LPMPP (HAKI)  
**Domain:** Research & Intellectual Property  
**Tools:** SQL Server Integration Services (SSIS), SQL Server 2019+

---

## 1. Overview

Dokumen ini menjelaskan arsitektur dan implementasi proses Extract, Transform, Load (ETL) untuk memindahkan data dari sumber (Flat Files/CSV) menuju Data Warehouse (`DM_LPMPP_DW`).

Proses ETL dirancang untuk menangani:

- Pembersihan data (Data Cleansing).
- Validasi referensial (Referential Integrity).
- Transformasi tipe data.
- Pemuatan ke skema Star Schema (Fact, Dimension, & Bridge).

## 2. ETL Architecture

Alur data dirancang menggunakan pendekatan **Staging Area** untuk meminimalkan beban pada sistem sumber dan memungkinkan validasi data sebelum masuk ke Data Warehouse utama.

```mermaid
graph LR
    A["Source: CSV Files"] -->|Extract| B["Staging Area (stg)"]
    B -->|Transform & Validate| C["Data Warehouse (dbo)"]
```

### Urutan Eksekusi (Control Flow)

Paket SSIS (`LPMPP_ETL.dtsx`) menjalankan tugas dengan urutan sebagai berikut:

1.  **Pre-Load Tasks (Truncate):** Membersihkan seluruh tabel di schema `stg` dan tabel fakta di `dbo` (untuk skenario _Full Reload_) menggunakan `Execute SQL Task`.
2.  **Staging Load:** Memuat data mentah dari CSV ke tabel Staging (`stg.Fact_...`, `stg.Dim_...`).
3.  **Dimension Load:** Memuat dan memperbarui tabel dimensi Master (`Dim_Inventor`, `Dim_JenisKI`, `Dim_Status`, `Dim_Date`).
4.  **Fact Load:** Memuat data transaksi ke `Fact_PengajuanKI` dengan validasi Lookup.
5.  **Bridge Load:** Memuat data relasi many-to-many ke `Bridge_Pengajuan_Inventor`.

---

## 3\. Detailed Transformation Logic

### A. Handling Data Quality (Derived Column)

Sebelum data dimuat ke tabel Fakta, transformasi logika diterapkan untuk menangani inkonsistensi data dari sumber CSV:

- **Empty Strings to NULL:** Kolom tanggal (`DateKey_Granted`, `DateKey_Kadaluwarsa`) dan biaya (`BiayaPendaftaran`) yang berisi string kosong `""` dikonversi menjadi `NULL` agar sesuai dengan tipe data database.
  - _Expression:_ `(LEN(TRIM(Column)) == 0) ? NULL(DT_I4) : (DT_I4)Column`
- **Empty Strings to Zero:** Kolom measure (`JumlahPengajuan`, `JumlahPaten`) yang kosong dikonversi menjadi `0`.
  - _Expression:_ `(LEN(TRIM(Column)) == 0) ? 0 : (DT_I4)Column`

### B. Surrogate Key Lookup

Semua _Natural Key_ dari sumber digantikan dengan _Surrogate Key_ integer menggunakan komponen **Lookup Transformation**:

| Lookup Component    | Source Key   | Target Table       | Error Handling                  |
| :------------------ | :----------- | :----------------- | :------------------------------ |
| **LKP_JenisKI**     | `JenisKIKey` | `dbo.Dim_JenisKI`  | Fail Component (Wajib Ada)      |
| **LKP_Status**      | `StatusKey`  | `dbo.Dim_Status`   | Fail Component (Wajib Ada)      |
| **LKP_Inventor**    | `NIP_NIM`    | `dbo.Dim_Inventor` | Fail Component (Wajib Ada)      |
| **LKP_DateGranted** | `DateKey`    | `dbo.Dim_Date`     | **Ignore Failure** (Boleh NULL) |

---

## 4\. Deployment & Execution Guide

### Prerequisites

1.  **Database:** Jalankan script SQL `01` s.d `06` pada folder `/sql` untuk menyiapkan database, tabel, index, dan partisi.
2.  **Source Files:** Pastikan file CSV sumber berada di lokasi yang dapat diakses oleh SSIS (default path perlu disesuaikan di Connection Manager).

### Cara Menjalankan (Visual Studio)

1.  Buka Solution `LPMPP_ETL.sln`.
2.  Cek **Connection Managers**:
    - `LocalHost.DM_LPMPP_DW`: Pastikan mengarah ke instance SQL Server yang benar.
    - `Flat File Connection Managers`: Update properti _File Name_ sesuai lokasi CSV di komputer lokal Anda.
3.  Tekan **Start** (F5).
4.  Pastikan seluruh komponen Control Flow berubah menjadi **Hijau (Success)**.

---

## 5\. Performance Optimization Feature

Paket ETL ini telah dioptimalkan untuk menangani volume data besar dengan fitur:

- **Bulk Insert:** Menggunakan mode _Fast Load_ pada OLE DB Destination.
- **Partition Awareness:** Data dimuat ke tabel fakta yang telah dipartisi (`PS_TahunPengajuan`), memungkinkan SQL Server mengelola penyimpanan fisik secara efisien.
- **Indexing:** Non-Clustered Index pada Foreign Key telah dibuat di database untuk mempercepat proses Lookup dan Reporting.

---

**Author:** Kelompok 6 - SD25-31007 Pergudangan Data  
**Last Updated:** November 2025

---
