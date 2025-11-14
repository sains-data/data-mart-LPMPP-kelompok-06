# Data Mart LPMPP Institut Teknologi Sumatera

Tugas Besar Pergudangan Data (SD25-31007)  
Kelompok 06

## Team Members

| NIM | Name | Role |
| :--- | :--- | :--- |
| 123450071 | Khairunnisa Maharani | Project Lead |
| 123450110 | Ihsan Maulana Yusuf | Database Designer |
| 123450040 | Aprilia Dewi Hutapea | ETL Developer |
| 122450061 | Kharisa Harvanny | BI Developer & QA |

## Business Domain

Unit yang dianalisis adalah **Lembaga Penjaminan Mutu dan Pengembangan Pembelajaran (LPMPP) ITERA**.

LPMPP bertanggung jawab untuk mengkoordinasikan, melaksanakan, dan mengevaluasi proses penjaminan mutu (seperti Akreditasi dan Audit Internal) serta pengembangan pembelajaran (seperti pengembangan Kurikulum, pelatihan Dosen, dan pengelolaan Karya Intelektual).

Lembaga ini menaungi **7 Pusat Layanan**:
1. Pusat Penjaminan Mutu (PPM)  
2. Pusat Kurikulum dan Pengembangan Pembelajaran (PKPP)  
3. Pusat Program Tahap Persiapan Bersama (PTPB)  
4. Pusat Kelola Karya Intelektual (PKKI)  
5. Pusat Halal (PH)  
6. Pusat Implementasi Inovasi (PII)  
7. Pusat Pengembangan Sumber Daya Manusia (PPSDM)

## Objectives

Tujuan dari data mart ini adalah untuk menyediakan *single source of truth* bagi pimpinan LPMPP untuk memantau Key Performance Indicators (KPI) dari ketujuh pusat layanan. Dashboard analitik akan dibuat untuk menjawab pertanyaan bisnis terkait akreditasi, produktivitas karya intelektual, layanan halal, dan asesmen mahasiswa.

## Key Performance Indicators (KPIs)

Data mart ini dirancang untuk melacak KPI utama LPMPP berdasarkan capaian "Highlight 2023–2024":

* **Akreditasi (PPM):** Melacak capaian akreditasi Program Studi (contoh capaian 2024: 3 Prodi "Unggul" dan 11 Prodi "Baik Sekali").  
* **Karya Intelektual (PKKI):** Melacak produktivitas KI (contoh capaian: Peringkat 7 Nasional – 92 Paten Sederhana; Peringkat 10 Nasional – 22 Paten).  
* **Layanan Halal (PH):** Memonitor progres layanan (contoh capaian: 200 produk didampingi dan 11 auditor halal baru tersertifikasi).  
* **Mutu Internal (PPM):** Memonitor jumlah auditor AMI tersertifikasi (contoh capaian: total 101 auditor).  
* **Layanan TPB (PTPB):** Melacak pelaksanaan asesmen (contoh capaian: 4.470 mahasiswa baru mengikuti Assessment Basic Science).  

## Architecture

* **Approach**: Kimball Dimensional Modeling  
* **Platform**: SQL Server on Azure VM  
* **ETL**: SQL Server Integration Services (SSIS)  
* **Visualization**: Power BI Desktop  

## Data Model

Data Mart terdiri dari beberapa skema bintang (star schema) yang berfokus pada proses bisnis utama:

* **Fact Tables:**
    * `Fact_Akreditasi`
    * `Fact_PengajuanKI`
    * `Fact_LayananHalal`
    * `Fact_AssessmentTPB`
    * `Fact_AuditMutuInternal`

* **Conformed Dimensions:**
    * `Dim_Date`
    * `Dim_ProgramStudi`
    * `Dim_Dosen`

## Repository Structure
```
├── README.md
├── docs/
│   ├── 01-requirements/
│   │   ├── business-requirements.md
│   │   └── data-sources.md
│   ├── 02-design/
│   │   ├── ERD.png
│   │   ├── dimensional-model.png
│   │   └── data-dictionary.xlsx
│   ├── 03-implementation/
│   │   ├── etl-documentation.md
│   │   ├── user-manual.pdf
│   │   └── operations-manual.pdf
│   └── presentations/
├── sql/
│   ├── 01_Create_Database.sql
│   ├── 02_Create_Dimensions.sql
│   ├── 03_Create_Facts.sql
│   ├── 04_Create_Indexes.sql
│   ├── 05_Create_Partitions.sql
│   └── 06_Create_Staging.sql
├── etl/
│   ├── packages/
│   └── scripts/
├── dashboards/
│   └── PowerBI files
└── tests/
    └── test scripts
```

## Documentation

* [Business Requirements](docs/01-requirements/business-requirements.pdf)  
* [Data Dictionary](docs/02-design/data-dictionary.xlsx)  
* [ETL Documentation](docs/03-implementation/etl-documentation.md)  
* [User Manual](docs/03-implementation/user-manual.pdf)  
* [Operations Manual](docs/03-implementation/operations-manual.pdf)  
