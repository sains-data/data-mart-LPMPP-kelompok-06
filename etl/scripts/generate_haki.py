"""
===========================================================================
FILE          : generate_haki.py
DESCRIPTION   : Script untuk generate data dummy HAKI (LPMPP) 
                mencakup Dimensi, Fakta, dan Bridge Table.
PROJECT       : Tugas Besar Pergudangan Data - Misi 2
AUTHOR        : Kelompok 6
CREATED DATE  : 2025-11-20
PYTHON VER    : Python 3.x (pandas, faker)
OUTPUT        : 5 CSV (Dim_JenisKI, Dim_Status, Dim_Inventor,
                      Dim_Date, Fact_PengajuanKI, Bridge_Pengajuan_Inventor)
===========================================================================
"""


import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker('id_ID')

print("=== MEMULAI GENERATE DATA DUMMY HAKI (LPMPP) ===")

# ==========================================
# 1. GENERATE DIMENSION TABLES
# ==========================================

# --- A. Dim_JenisKI ---
print("1. Generating Dim_JenisKI...")
data_jenis_ki = [
    {'JenisKIKey': 1, 'Nama_JenisKI': 'Paten'},
    {'JenisKIKey': 2, 'Nama_JenisKI': 'Paten Sederhana'},
    {'JenisKIKey': 3, 'Nama_JenisKI': 'Hak Cipta'},
    {'JenisKIKey': 4, 'Nama_JenisKI': 'Merek'},
    {'JenisKIKey': 5, 'Nama_JenisKI': 'Desain Industri'},
    {'JenisKIKey': 6, 'Nama_JenisKI': 'Rahasia Dagang'}
]
df_jenis_ki = pd.DataFrame(data_jenis_ki)
df_jenis_ki.to_csv('Dim_JenisKI.csv', index=False)

# --- B. Dim_Status ---
print("2. Generating Dim_Status...")
data_status = [
    {'StatusKey': 1, 'Nama_Status': 'Diajukan (Submitted)'},
    {'StatusKey': 2, 'Nama_Status': 'Pemeriksaan Formalitas'},
    {'StatusKey': 3, 'Nama_Status': 'Publikasi'},
    {'StatusKey': 4, 'Nama_Status': 'Pemeriksaan Substantif'},
    {'StatusKey': 5, 'Nama_Status': 'Diberi (Granted)'},
    {'StatusKey': 6, 'Nama_Status': 'Ditolak (Rejected)'},
    {'StatusKey': 7, 'Nama_Status': 'Ditarik Kembali (Withdrawn)'},
    {'StatusKey': 8, 'Nama_Status': 'Kadaluwarsa (Expired)'}
]
df_status = pd.DataFrame(data_status)
df_status.to_csv('Dim_Status.csv', index=False)

# --- C. Dim_Inventor (Dosen/Mahasiswa) ---
print("3. Generating Dim_Inventor...")
data_inventor = []
prodi_list = ['Sains Data', 'Teknik Informatika', 'Teknik Sipil', 'Farmasi', 'Matematika', 'Fisika', 'Biologi', 'Teknik Elektro']
fakultas_map = {
    'Sains Data': 'Fakultas Sains', 'Matematika': 'Fakultas Sains', 'Fisika': 'Fakultas Sains', 
    'Biologi': 'Fakultas Sains', 'Farmasi': 'Fakultas Sains',
    'Teknik Informatika': 'FTI', 'Teknik Elektro': 'FTI', 'Teknik Sipil': 'FTIK'
}

for i in range(1, 101): # Bikin 100 Inventor
    prodi = random.choice(prodi_list)
    data_inventor.append({
        'InventorKey': i,
        'NIP_NIM': fake.unique.random_number(digits=10),
        'Nama_Inventor': fake.name(),
        'Nama_Prodi': prodi,
        'Nama_Fakultas': fakultas_map[prodi]
    })
df_inventor = pd.DataFrame(data_inventor)
df_inventor.to_csv('Dim_Inventor.csv', index=False)

# --- D. Dim_Date (2020 - Sekarang) ---
print("4. Generating Dim_Date...")
data_date = []
start_date = datetime(2020, 1, 1)
end_date = datetime.now()
delta = end_date - start_date

for i in range(delta.days + 1):
    day = start_date + timedelta(days=i)
    quarter = (day.month - 1) // 3 + 1
    data_date.append({
        'DateKey': int(day.strftime('%Y%m%d')), # Format YYYYMMDD (Integer)
        'FullDate': day.strftime('%Y-%m-%d'),
        'MonthName': day.strftime('%B'),
        'Quarter': f'Q{quarter}',
        'Year': day.year
    })
df_date = pd.DataFrame(data_date)
df_date.to_csv('Dim_Date.csv', index=False)

# ==========================================
# 2. GENERATE FACT TABLE (Fact_PengajuanKI)
# ==========================================

print("5. Generating Fact_PengajuanKI...")
data_fact = []
data_bridge = [] # Untuk Bridge Table

# Bikin 5000 data pengajuan
for i in range(1, 10001):
    # Random Dates logic
    tgl_daftar = random.choice(data_date)['DateKey']
    
    # Random Status & Jenis
    jenis_ki = random.choice(data_jenis_ki)
    status = random.choice(data_status)
    
    # Logika Tanggal: Granted pasti setelah Daftar
    tgl_granted = None
    tgl_kadaluwarsa = None
    
    if status['StatusKey'] == 5: # Kalau Granted
        # Granted 6 bulan - 2 tahun setelah daftar
        date_obj = datetime.strptime(str(tgl_daftar), '%Y%m%d') + timedelta(days=random.randint(180, 730))
        tgl_granted = int(date_obj.strftime('%Y%m%d'))
    
    # Biaya Pendaftaran (Random tapi logis dikit)
    biaya = random.choice([500000, 1000000, 1500000, 2000000])
    
    # Measures logic (One-Hot Encoding style based on Excel requirement)
    is_paten = 1 if jenis_ki['JenisKIKey'] == 1 else 0
    is_paten_sederhana = 1 if jenis_ki['JenisKIKey'] == 2 else 0
    is_hak_cipta = 1 if jenis_ki['JenisKIKey'] == 3 else 0
    
    data_fact.append({
        'PengajuanKey': i,
        'DateKey_Daftar': tgl_daftar,
        'DateKey_Granted': tgl_granted, # Bisa NULL (None)
        'DateKey_Kadaluwarsa': tgl_kadaluwarsa, # Bisa NULL
        'JenisKIKey': jenis_ki['JenisKIKey'],
        'StatusKey': status['StatusKey'],
        'JumlahPengajuan': 1,
        'BiayaPendaftaran': biaya,
        'JumlahPaten': is_paten,
        'JumlahPatenSederhana': is_paten_sederhana,
        'JumlahHakCipta': is_hak_cipta
    })

    # ==========================================
    # 3. GENERATE BRIDGE TABLE
    # ==========================================
    # Satu pengajuan bisa punya 1-3 inventor (Ketua & Anggota)
    num_inventors = random.choices([1, 2, 3], weights=[60, 30, 10])[0]
    selected_inventors = random.sample(data_inventor, k=num_inventors)
    
    for idx, inv in enumerate(selected_inventors):
        peran = 'Ketua Inventor' if idx == 0 else 'Anggota Inventor'
        data_bridge.append({
            'PengajuanKey': i,
            'InventorKey': inv['InventorKey'],
            'Peran_Inventor': peran
        })

df_fact = pd.DataFrame(data_fact)
df_fact.to_csv('Fact_PengajuanKI.csv', index=False)

df_bridge = pd.DataFrame(data_bridge)
df_bridge.to_csv('Bridge_Pengajuan_Inventor.csv', index=False)

print(f"SUKSES! 5 File CSV berhasil dibuat: Fact ({len(df_fact)} rows), Bridge ({len(df_bridge)} rows).")