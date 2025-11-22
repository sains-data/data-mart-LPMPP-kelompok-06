# Data Mart LPMPP Institut Teknologi Sumatera

Tugas Besar Pergudangan Data (SD25-31007)  
Kelompok 06

## Team Members

| NIM | Name | Role | Email |
| :--- | :--- | :--- | :--- |
| 123450071 | Khairunnisa Maharani | Project Lead | Khairunnisa.123450071@student.itera.ac.id |
| 123450110 | Ihsan Maulana Yusuf | Database Designer |ihsan.123450110@student.itera.ac.id |
| 123450040 | Aprilia Dewi Hutapea | ETL Developer | aprilia.123450040@student.itera.ac.id |
| 122450061 | Kharisa Harvanny | BI Developer & QA | kharisa.122450061@student.itera.ac.id |

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

Tujuan dari proyek *pilot* data mart ini adalah untuk merancang model analitik yang terfokus pada satu domain, yaitu **Pusat Kelola Karya Intelektual (PKKI)**.

Desain data mart ini akan menjadi *blueprint* (cetak biru) untuk usulan pengembangan data mart di 6 pusat layanan lainnya di masa depan.

## Key Performance Indicators (KPIs)

Data mart ini dirancang untuk melacak KPI utama dari domain pilot project, **Pusat Kelola Karya Intelektual (PKKI)**, berdasarkan capaian "Highlight 2023–2024":

* **Karya Intelektual (PKKI):** Melacak produktivitas KI (contoh capaian: Peringkat 7 Nasional – 92 Paten Sederhana; Peringkat 10 Nasional – 22 Paten)

## Architecture

* **Approach**: Kimball Dimensional Modeling (Fokus pada 1 Star Schema)  
* **Platform**: SQL Server on Azure VM  
* **ETL**: SQL Server Integration Services (SSIS)  
* **Visualization**: Power BI Desktop  

## Data Model (Scope Misi 1)

Data Model untuk Misi 1 ini difokuskan pada **satu Star Schema** untuk domain PKKI, sesuai dengan *deliverables* `dimensional-model.png` dan `data-dictionary.xlsx`.

* **Fact Table:**
    * `Fact_PengajuanKI`

* **Dimension Tables:**
    * `Dim_Date` (Kapan diajukan)
    * `Dim_Inventor` (Siapa yang mengajukan)
    * `Dim_JenisKI` (Jenis karya: Paten, Paten Sederhana, dll)
    * `Dim_Status` (Status pengajuan: Granted, Pending, dll)

## Repository Structure
```
├── README.md
├── docs/
│   ├── 01-requirements/
│   │   ├── business-requirements.pdf
│   │   └── data-sources.md
│   ├── 02-design/
│   │   ├── ERD.png
│   │   ├── dimensional-model.png
│   │   ├── data-dictionary.xlsx
│   │   ├── ETL_Mapping_Document.xlsx
│   │   └── ETL_Architecture_Document.pdf
│   ├── 03-implementation/
│   │   ├── Technical_Documentation.pdf 
│   │   └── etl-documentation.md           
│   └── 04-testing/                         
│       ├── Data_Quality_Report.pdf
│       ├── Quality_Metrics_Summary.pdf
│       └── Performance_Test_Report.pdf 
├── sql/
│   ├── 01_Create_Database.sql
│   ├── 02_Create_Dimensions.sql
│   ├── 03_Create_Facts.sql
│   ├── 04_Create_Indexes.sql
│   ├── 05_Create_Partitions.sql
│   ├── 06_Create_Staging.sql
│   ├── 08_Data_Quality_Checks.sql      
│   └── 09_Test_Queries.sql             
├── etl/
│   ├── packages/
│   │   └── LPMPP_ETL.dtsx             
│   ├── scripts/
│   │   └── generate_haki.py
│   └── source_data/
│       ├── Bridge_Pengajuan_Inventor.csv
│       ├── Dim_Date.csv
│       ├── Dum_Inventor.csv
│       ├── Dim_JenisKI.csv
│       ├── Dim_Status.csv
│       └── Fact_PengajuanKI.csv           
├── dashboards/
│   └── (Masih kosong, nanti buat Misi 3)
└── tests/
    └── (Opsional)
```

## Documentation

* [Business Requirements](docs/01-requirements/business-requirements.pdf)  
* [Data Dictionary](docs/02-design/data-dictionary.xlsx)  
* [ETL Documentation](docs/03-implementation/etl-documentation.md)  
* [User Manual](docs/03-implementation/user-manual.pdf)  
* [Operations Manual](docs/03-implementation/operations-manual.pdf)
