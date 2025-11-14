# **ANALISIS SUMBER DATA (DATA SOURCE ANALYSIS)**

Dokumen ini mengidentifikasi sumber data operasional (OLTP) yang akan digunakan untuk membangun **Data Mart Pusat Kelola Karya Intelektual (PKKI) LPMPP ITERA**.

---

## **1. Sumber Data Utama**

Berdasarkan analisis kebutuhan bisnis, sumber data utama untuk Data Mart PKKI adalah **database transaksional (OLTP) dari portal layanan PKKI**.

---

## **2. Ringkasan Sumber Data**

| **Data Source**                       | **Tipe**   | **Perkiraan Volume** | **Frekuensi Update** | **Keterangan**                                                                                                                     |
| ------------------------------------- | ---------- | -------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Database Portal HKI (hki.itera.ac.id) | SQL Server | ~5.000 baris         | Per Event (Ad-hoc)   | Berisi data master Inventor (Dosen/Mahasiswa) dan data transaksi Pengajuan HKI (Paten, Paten Sederhana, Hak Cipta, dan lain-lain). |

---

## **3. Analisis Detail Sumber Data**

### **3.1 Struktur Data**

Database bersifat **relasional**, terdiri dari tabel utama seperti:

- **Inventor** (terhubung dengan SSO ITERA untuk data dosen/mahasiswa)
- **PengajuanHKI** (berisi transaksi pendaftaran Paten, Paten Sederhana, Hak Cipta, dll.)

### **3.2 Volume Data**

- Perkiraan total saat ini sekitar **ribuan baris**.
- Berdasarkan tren capaian PKKI, pertumbuhan data diprediksi sekitar **100–200 baris per tahun**.

### **3.3 Kualitas Data**

- Kualitas data relatif baik.
- Data inventor (nama, NIP/NIM, prodi) valid karena bersumber langsung dari **SSO ITERA**.
- Konsistensi transaksi HKI cukup tinggi karena proses input dilakukan oleh staf PKKI.

### **3.4 Frekuensi Pembaruan**

- Data diperbarui **per event** (ad-hoc).
- Update terjadi saat:
  - Ada pengajuan HKI baru,
  - Perubahan status pengajuan,
  - Revisi dokumen atau perbaikan berkas.
