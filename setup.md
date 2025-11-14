# Panduan Setup VM Azure untuk Data Mart Portal

## Daftar Isi

1. [Persiapan](#1-persiapan)
2. [Membuat VM di Azure](#2-membuat-vm-di-azure)
3. [Koneksi ke VM](#3-koneksi-ke-vm)
4. [Install Software Dependencies](#4-install-software-dependencies)
5. [Setup Database SQL Server](#5-setup-database-sql-server)
6. [Clone dan Setup Backend](#6-clone-dan-setup-backend)
7. [Setup Frontend](#7-setup-frontend)
8. [Setup Apache Airflow](#8-setup-apache-airflow)
9. [Setup Apache Superset](#9-setup-apache-superset)
10. [Configure Nginx Reverse Proxy](#10-configure-nginx-reverse-proxy)
11. [Setup SSL Certificate](#11-setup-ssl-certificate)
12. [Testing dan Verifikasi](#12-testing-dan-verifikasi)

---

## 1. Persiapan

### 1.1 Yang Anda Butuhkan

- **Azure Account** dengan credits/subscription aktif
- **SSH Client** (Terminal di Mac/Linux, PuTTY di Windows)
- **Text Editor** untuk edit file (nano, vim, atau VS Code Remote SSH)
- **Git** untuk clone repository
- **Koneksi Internet** yang stabil

### 1.2 Informasi yang Perlu Disiapkan

Catat informasi berikut sebelum mulai:

```
Data Mart Code: _________ (contoh: FSRD)
Database Name: datamart_____olap (contoh: datamart_fsrd_olap)
Domain/IP: _________ (akan didapat setelah VM dibuat)
Admin Username: _________ (untuk VM)
Admin Password: _________ (untuk VM)
```

---

## 2. Membuat VM di Azure

### 2.1 Login ke Azure Portal

1. Buka https://portal.azure.com
2. Login dengan akun Azure Anda

### 2.2 Create Virtual Machine

1. **Klik "Create a resource"** → "Virtual Machine"

2. **Basics Tab:**

   ```
   Subscription: [Pilih subscription Anda]
   Resource Group: [Buat baru atau pilih existing] → contoh: "rg-datamart-fsrd"
   Virtual Machine Name: vm-datamart-fsrd
   Region: Southeast Asia (atau terdekat)
   Availability Options: No infrastructure redundancy required
   Security Type: Standard
   Image: Ubuntu Server 22.04 LTS - x64 Gen2
   Size: Standard_B2s (2 vcpus, 4 GiB memory) - MINIMUM
          Standard_B2ms (2 vcpus, 8 GiB memory) - RECOMMENDED
   ```

3. **Administrator Account:**

   ```
   Authentication type: Password (lebih mudah untuk pemula)
   Username: azureuser
   Password: [Buat password kuat, minimal 12 karakter]
   Confirm Password: [Ulangi password]
   ```

4. **Inbound Port Rules:**

   ```
   Public inbound ports: Allow selected ports
   Select inbound ports:
   ✓ HTTP (80)
   ✓ HTTPS (443)
   ✓ SSH (22)
   ```

5. **Disks Tab:**

   ```
   OS disk type: Standard SSD (locally-redundant storage)
   Encryption type: Default
   Delete with VM: ✓ (checked)
   ```

6. **Networking Tab:**

   ```
   Virtual network: [Auto-created atau pilih existing]
   Subnet: default
   Public IP: [Auto-created]
   NIC network security group: Basic
   Public inbound ports: Allow selected ports (80, 443, 22)
   Delete public IP and NIC when VM is deleted: ✓
   ```

7. **Management Tab:** (Biarkan default)

8. **Review + Create:**
   - Review semua konfigurasi
   - Klik **"Create"**
   - Tunggu 3-5 menit sampai deployment selesai

### 2.3 Dapatkan Public IP Address

1. Setelah deployment selesai, klik **"Go to resource"**
2. Di Overview page, catat **Public IP address**
   ```
   Contoh: 20.198.123.45
   ```
3. **PENTING:** Save IP ini, Anda akan sering menggunakannya

---

## 3. Koneksi ke VM

### 3.1 Via SSH (Mac/Linux/Windows 10+)

```bash
# Ganti dengan IP dan username Anda
ssh azureuser@20.198.123.45

# Ketik 'yes' jika ditanya tentang fingerprint
# Masukkan password yang Anda buat tadi
```

### 3.2 Via PuTTY (Windows)

1. Download PuTTY dari https://www.putty.org/
2. Buka PuTTY
3. **Host Name:** 20.198.123.45
4. **Port:** 22
5. **Connection Type:** SSH
6. Klik **Open**
7. Login dengan username dan password

### 3.3 Verifikasi Koneksi

Setelah login, jalankan:

```bash
# Check OS version
cat /etc/os-release

# Check available memory
free -h

# Check disk space
df -h

# Update package list
sudo apt update
```

---

## 4. Install Software Dependencies

### 4.1 Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 4.2 Install Essential Tools

```bash
# Install basic tools
sudo apt install -y curl wget git vim nano unzip software-properties-common

# Install build essentials
sudo apt install -y build-essential
```

### 4.3 Install Node.js (Backend)

```bash
# Install Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

### 4.4 Install SQL Server 2022

```bash
# Download Microsoft repository keys
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# Add SQL Server repository
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)"

# Install SQL Server
sudo apt update
sudo apt install -y mssql-server

# Configure SQL Server
sudo /opt/mssql/bin/mssql-conf setup

# Pilih edition:
# Ketik: 2 (untuk Developer edition - GRATIS)
# Accept license: yes
# Set SA password: [Buat password kuat untuk SQL Server]
# Confirm password: [Ulangi password]

# Verify SQL Server running
systemctl status mssql-server

# Install SQL Server command-line tools
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

sudo apt update
sudo ACCEPT_EULA=Y apt install -y mssql-tools18 unixodbc-dev

# Add tools to PATH
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

# Test connection
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C -Q "SELECT @@VERSION"
```

# Tambah repository Deadsnakes (berisi versi Python terbaru)

```
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
```

# Install Python 3.11 beserta dev tools dan venv

```
sudo apt install -y python3.11 python3.11-venv python3.11-dev
```

# Install pip khusus untuk Python 3.11

```
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11
```

# Tambahkan lokasi pip user ke PATH (agar pip3.11 bisa diakses)

```
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

# Verifikasi versi Python 3.11 (tidak mengganti default sistem)

```
python3.11 --version
pip3.11 --version
```

### 4.6 Install Docker (untuk Superset - opsional tapi recommended)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version

# IMPORTANT: Logout and login again untuk activate docker group
exit
# SSH lagi ke VM
```

### 4.7 Install Nginx

```bash
sudo apt install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify
sudo systemctl status nginx

# Test di browser: http://YOUR_VM_IP
# Anda harus lihat "Welcome to nginx" page
```

---

## 5. Setup Database SQL Server

### 5.1 Create Data Mart Database

```bash
# Login to SQL Server
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C

# Buat database (ganti FSRD dengan kode mart Anda)
CREATE DATABASE datamart_fsrd_olap;
GO

# Verify
SELECT name FROM sys.databases;
GO

# Exit
EXIT
```

### 5.2 Create Star Schema

```bash
# Download atau copy script create-fsrd-star-schema.sql dari repository
# Atau buat file baru
nano ~/create-star-schema.sql
```

Paste script star schema (contoh untuk FSRD):

```sql
USE datamart_fsrd_olap;
GO

-- Dimension: Date
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    week INT,
    day_of_month INT,
    day_of_week INT,
    day_name VARCHAR(20),
    is_weekend BIT,
    semester VARCHAR(20)
);
GO

-- Dimension: Mahasiswa
CREATE TABLE dim_mahasiswa (
    mahasiswa_key INT PRIMARY KEY IDENTITY(1,1),
    nim VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100),
    angkatan INT,
    status VARCHAR(20),
    email VARCHAR(100),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Dimension: Program Studi
CREATE TABLE dim_program (
    program_key INT PRIMARY KEY IDENTITY(1,1),
    kode_program VARCHAR(10) UNIQUE NOT NULL,
    nama_program VARCHAR(100),
    jenjang VARCHAR(20),
    fakultas VARCHAR(100),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Fact: Karya Seni
CREATE TABLE fact_karya (
    karya_id INT PRIMARY KEY IDENTITY(1,1),
    mahasiswa_key INT FOREIGN KEY REFERENCES dim_mahasiswa(mahasiswa_key),
    program_key INT FOREIGN KEY REFERENCES dim_program(program_key),
    tanggal_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    judul VARCHAR(200),
    jenis_karya VARCHAR(50),
    media VARCHAR(50),
    nilai DECIMAL(5,2),
    status_pameran VARCHAR(20),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Fact: Pameran
CREATE TABLE fact_pameran (
    pameran_id INT PRIMARY KEY IDENTITY(1,1),
    karya_id INT FOREIGN KEY REFERENCES fact_karya(karya_id),
    tanggal_mulai_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    tanggal_selesai_key INT FOREIGN KEY REFERENCES dim_date(date_key),
    nama_pameran VARCHAR(200),
    lokasi VARCHAR(100),
    jumlah_pengunjung INT,
    revenue DECIMAL(15,2),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Create indexes untuk performance
CREATE INDEX idx_fact_karya_mahasiswa ON fact_karya(mahasiswa_key);
CREATE INDEX idx_fact_karya_program ON fact_karya(program_key);
CREATE INDEX idx_fact_karya_tanggal ON fact_karya(tanggal_key);
CREATE INDEX idx_fact_pameran_tanggal_mulai ON fact_pameran(tanggal_mulai_key);
GO
```

Execute script:

```bash
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C -i ~/create-star-schema.sql
```

### 5.3 Insert Sample Data (Optional)

```bash
nano ~/insert-sample-data.sql
```

```sql
USE datamart_fsrd_olap;
GO

-- Sample dates
INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name, week, day_of_month, day_of_week, day_name, is_weekend, semester)
VALUES
(20240101, '2024-01-01', 2024, 1, 1, 'January', 1, 1, 1, 'Monday', 0, '2023/2024 Genap'),
(20240215, '2024-02-15', 2024, 1, 2, 'February', 7, 15, 4, 'Thursday', 0, '2023/2024 Genap');
GO

-- Sample programs
INSERT INTO dim_program (kode_program, nama_program, jenjang, fakultas)
VALUES
('DKV', 'Desain Komunikasi Visual', 'S1', 'Fakultas Seni Rupa dan Desain'),
('SR', 'Seni Rupa', 'S1', 'Fakultas Seni Rupa dan Desain');
GO

-- Sample students
INSERT INTO dim_mahasiswa (nim, nama, angkatan, status, email)
VALUES
('12345678', 'Budi Santoso', 2021, 'Aktif', 'budi@example.com'),
('12345679', 'Ani Lestari', 2022, 'Aktif', 'ani@example.com');
GO
```

Execute:

```bash
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C -i ~/insert-sample-data.sql
```

---

## 6. Clone dan Setup Backend

### 6.1 Clone Repository

```bash
# Masuk ke home directory
cd ~

# Clone repository (ganti dengan URL repository Anda)
git clone https://github.com/YOUR_USERNAME/template-mart.git

# Masuk ke directory backend
cd template-mart/backend
```

### 6.2 Install Dependencies

```bash
npm install
```

### 6.3 Configure Environment Variables

```bash
# Copy .env.example ke .env
cp .env.example .env

# Edit .env
nano .env
```

Edit file `.env` (sesuaikan dengan setup Anda):

```env
# Server Configuration
NODE_ENV=production
PORT=3000
API_BASE_URL=http://localhost:3000

# Database Configuration - OLTP
DB_OLTP_SERVER=localhost
DB_OLTP_PORT=1433
DB_OLTP_DATABASE=insightera_oltp
DB_OLTP_USER=sa
DB_OLTP_PASSWORD=YourSAPassword
DB_OLTP_ENCRYPT=true
DB_OLTP_TRUST_SERVER_CERTIFICATE=true

# Database Configuration - OLAP (untuk multi-mart mode)
# Format: DATAMART_CODES=CODE1,CODE2,CODE3
DATAMART_CODES=FSRD

# FSRD Data Mart Configuration
DB_FSRD_SERVER=localhost
DB_FSRD_PORT=1433
DB_FSRD_DATABASE=datamart_fsrd_olap
DB_FSRD_USER=sa
DB_FSRD_PASSWORD=YourSAPassword
DB_FSRD_ENCRYPT=true
DB_FSRD_TRUST_SERVER_CERTIFICATE=true

# Mart Mode: 'single' atau 'multi'
MART_MODE=single
MART_CODE=FSRD

# JWT Secret (generate random string)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h

# Airflow Configuration
AIRFLOW_BASE_URL=http://localhost:8080
AIRFLOW_USERNAME=admin
AIRFLOW_PASSWORD=admin

# Superset Configuration
SUPERSET_BASE_URL=http://localhost:8088
SUPERSET_USERNAME=admin
SUPERSET_PASSWORD=admin

# File Upload
MAX_FILE_SIZE=104857600
UPLOAD_DIR=./temp/uploads

# Logging
LOG_LEVEL=info
LOG_FILE=./logs/app.log
```

Save file (Ctrl+O, Enter, Ctrl+X)

### 6.4 Setup Prisma

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations (jika ada)
npx prisma db push

# Seed database dengan admin user
npm run seed
```

### 6.5 Test Backend

```bash
# Development mode
npm run dev

# Jika berhasil, Anda akan lihat:
# Server running on port 3000
# Connected to OLTP database
# Connected to FSRD data mart

# Test API (buka terminal baru)
curl http://localhost:3000/api/health

# Expected response:
# {"success":true,"message":"API is healthy"}
```

### 6.6 Setup PM2 untuk Production

```bash
# Install PM2 globally
sudo npm install -g pm2

# Start backend dengan PM2
pm2 start npm --name "datamart-backend" -- run start

# Setup auto-restart on reboot
pm2 startup
# Copy dan jalankan command yang muncul

pm2 save

# Check status
pm2 status
pm2 logs datamart-backend
```

---

## 7. Setup Frontend

### 7.1 Masuk ke Directory Frontend

```bash
cd ~/template-mart/frontend
```

### 7.2 Install Dependencies

```bash
npm install
```

### 7.3 Configure Environment

```bash
# Copy .env.example ke .env
cp .env.example .env.production

# Edit .env.production
nano .env.production
```

Edit file:

```env
VITE_API_BASE_URL=http://YOUR_VM_IP:3000/api
VITE_APP_NAME=FSRD Data Mart Portal
VITE_MART_CODE=FSRD
```

### 7.4 Build Frontend

```bash
npm run build

# Output akan ada di folder 'dist'
# Folder ini yang akan di-serve oleh Nginx
```

---

## 8. Setup Apache Airflow

### 8.1 Create Airflow Directory

```bash
cd ~
mkdir airflow
cd airflow

# Set AIRFLOW_HOME
echo 'export AIRFLOW_HOME=~/airflow' >> ~/.bashrc
source ~/.bashrc
```

### 8.2 Install Airflow

```bash
# Set Airflow version
AIRFLOW_VERSION=2.8.0
PYTHON_VERSION="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

# Install Airflow with MSSQL provider
pip3 install "apache-airflow[mssql]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# Install additional providers
pip3 install apache-airflow-providers-microsoft-mssql
```

### 8.3 Initialize Airflow Database

```bash
# Initialize database
airflow db init

# Create admin user
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin
```

### 8.4 Configure Airflow

```bash
nano ~/airflow/airflow.cfg
```

Edit beberapa konfigurasi:

```ini
[core]
dags_folder = /home/azureuser/airflow/dags
load_examples = False

[webserver]
web_server_port = 8080
expose_config = True

[api]
auth_backends = airflow.api.auth.backend.basic_auth
```

### 8.5 Create DAGs Directory

```bash
mkdir -p ~/airflow/dags
```

### 8.6 Create Sample ETL DAG

```bash
nano ~/airflow/dags/fsrd_etl.py
```

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import pyodbc

default_args = {
    'owner': 'datamart',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'fsrd_etl_daily',
    default_args=default_args,
    description='Daily ETL for FSRD Data Mart',
    schedule_interval=timedelta(days=1),
    catchup=False
)

def extract_data():
    print("Extracting data from OLTP...")
    # Your ETL logic here

def transform_data():
    print("Transforming data...")

def load_data():
    print("Loading data to data mart...")

extract_task = PythonOperator(
    task_id='extract',
    python_callable=extract_data,
    dag=dag,
)

transform_task = PythonOperator(
    task_id='transform',
    python_callable=transform_data,
    dag=dag,
)

load_task = PythonOperator(
    task_id='load',
    python_callable=load_data,
    dag=dag,
)

extract_task >> transform_task >> load_task
```

### 8.7 Start Airflow

```bash
# Start webserver (terminal 1)
airflow webserver --port 8080 &

# Start scheduler (terminal 2)
airflow scheduler &

# Access Airflow UI: http://YOUR_VM_IP:8080
# Login: admin / admin
```

### 8.8 Setup PM2 untuk Airflow

```bash
# Create start scripts
cat > ~/airflow/start-webserver.sh << 'EOF'
#!/bin/bash
export AIRFLOW_HOME=~/airflow
airflow webserver --port 8080
EOF

cat > ~/airflow/start-scheduler.sh << 'EOF'
#!/bin/bash
export AIRFLOW_HOME=~/airflow
airflow scheduler
EOF

chmod +x ~/airflow/start-webserver.sh
chmod +x ~/airflow/start-scheduler.sh

# Start dengan PM2
pm2 start ~/airflow/start-webserver.sh --name airflow-webserver
pm2 start ~/airflow/start-scheduler.sh --name airflow-scheduler

pm2 save
```

---

## 9. Setup Apache Superset

### 9.1 Install Superset (via Docker - RECOMMENDED)

```bash
cd ~
mkdir superset
cd superset

# Clone Superset
git clone https://github.com/apache/superset.git
cd superset

# Start Superset dengan Docker Compose
docker-compose -f docker-compose-non-dev.yml up -d

# Tunggu 2-3 menit untuk initialization

# Check logs
docker-compose logs -f

# Access: http://YOUR_VM_IP:8088
# Default login: admin / admin
```

### 9.2 Alternative: Install via pip

```bash
cd ~
python3 -m venv superset_env
source superset_env/bin/activate

pip install apache-superset
pip install pymssql

# Initialize database
superset db upgrade

# Create admin user
export FLASK_APP=superset
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname User \
    --email admin@example.com \
    --password admin

# Initialize Superset
superset init

# Start Superset
superset run -h 0.0.0.0 -p 8088 --with-threads --reload --debugger &
```

### 9.3 Configure SQL Server Connection in Superset

1. Login ke Superset: http://YOUR_VM_IP:8088
2. **Settings** → **Database Connections** → **+ Database**
3. **Supported Databases:** Microsoft SQL Server
4. **SQLAlchemy URI:**
   ```
   mssql+pymssql://sa:YourSAPassword@localhost:1433/datamart_fsrd_olap
   ```
5. **Test Connection** → **Connect**

### 9.4 Create Sample Dashboard

1. **SQL Lab** → New Query
2. Select database: `datamart_fsrd_olap`
3. Run query:
   ```sql
   SELECT
       p.nama_program,
       COUNT(*) as total_karya,
       AVG(nilai) as avg_nilai
   FROM fact_karya f
   JOIN dim_program p ON f.program_key = p.program_key
   GROUP BY p.nama_program
   ```
4. **Save** → **Explore** → Create Chart
5. Create Dashboard dan add chart

---

## 10. Configure Nginx Reverse Proxy

### 10.1 Create Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/datamart
```

Paste configuration:

```nginx
# Frontend
server {
    listen 80;
    server_name YOUR_VM_IP;  # Ganti dengan IP atau domain Anda

    # Frontend Static Files
    location / {
        root /home/azureuser/template-mart/frontend/dist;
        try_files $uri $uri/ /index.html;

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Airflow
    location /airflow {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Superset
    location /superset {
        proxy_pass http://localhost:8088;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 10.2 Enable Site

```bash
# Create symlink
sudo ln -s /etc/nginx/sites-available/datamart /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## 11. Setup SSL Certificate (Optional tapi Recommended)

### 11.1 Install Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 11.2 Obtain Certificate (Butuh Domain)

```bash
# Ganti dengan domain Anda
sudo certbot --nginx -d yourdomain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose: Redirect HTTP to HTTPS (option 2)
```

### 11.3 Auto-renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Crontab sudah auto-configured
```

---

## 12. Testing dan Verifikasi

### 12.1 Test Backend API

```bash
# Health check
curl http://YOUR_VM_IP/api/health

# Get app config
curl http://YOUR_VM_IP/api/config/app

# Get mart mode
curl http://YOUR_VM_IP/api/config/mart-mode
```

### 12.2 Test Frontend

Buka browser: `http://YOUR_VM_IP`

Checklist:

- [ ] Homepage loads
- [ ] Can login (jika ada auth)
- [ ] Dashboard menampilkan data mart info
- [ ] Reports bisa dijalankan
- [ ] Query Builder berfungsi
- [ ] Schema Explorer menampilkan tables
- [ ] File upload works
- [ ] ETL Monitor shows Airflow jobs

### 12.3 Test Database Connection

```bash
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C -Q "SELECT name FROM sys.databases"

# Verify your data mart database exists
```

### 12.4 Test Airflow

```bash
# Check DAGs
airflow dags list

# Test DAG
airflow dags test fsrd_etl_daily 2024-01-01

# Access UI: http://YOUR_VM_IP/airflow
```

### 12.5 Test Superset

```bash
# Access: http://YOUR_VM_IP/superset
# Login: admin / admin
# Verify database connection
# Try running SQL query
```

### 12.6 Check All Services

```bash
# PM2 processes
pm2 status

# Should show:
# - datamart-backend (online)
# - airflow-webserver (online)
# - airflow-scheduler (online)

# Nginx
sudo systemctl status nginx

# SQL Server
systemctl status mssql-server

# Docker (jika pakai Superset via Docker)
docker ps
```

---

## Troubleshooting

### Port Sudah Digunakan

```bash
# Check port usage
sudo lsof -i :3000  # Backend
sudo lsof -i :8080  # Airflow
sudo lsof -i :8088  # Superset

# Kill process jika perlu
sudo kill -9 <PID>
```

### Nginx 502 Bad Gateway

```bash
# Check backend running
pm2 status

# Check backend logs
pm2 logs datamart-backend

# Restart backend
pm2 restart datamart-backend
```

### SQL Server Connection Failed

```bash
# Check SQL Server status
systemctl status mssql-server

# Restart SQL Server
sudo systemctl restart mssql-server

# Check SQL Server logs
sudo tail -f /var/opt/mssql/log/errorlog
```

### Permission Denied

```bash
# Fix ownership
sudo chown -R azureuser:azureuser ~/template-mart

# Fix permissions
chmod +x ~/airflow/start-*.sh
```

### Out of Memory

```bash
# Check memory
free -h

# Check swap
swapon --show

# Add swap if needed (2GB)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## Maintenance Commands

### Update Application

```bash
cd ~/template-mart
git pull

# Update backend
cd backend
npm install
pm2 restart datamart-backend

# Update frontend
cd ../frontend
npm install
npm run build
```

### Backup Database

```bash
# Backup script
sqlcmd -S localhost -U sa -P 'YourSAPassword' -C -Q "BACKUP DATABASE datamart_fsrd_olap TO DISK = '/var/opt/mssql/backup/fsrd_$(date +%Y%m%d).bak' WITH FORMAT"
```

### View Logs

```bash
# Backend logs
pm2 logs datamart-backend

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Airflow logs
tail -f ~/airflow/logs/scheduler/latest/fsrd_etl_daily/*.log

# SQL Server logs
sudo tail -f /var/opt/mssql/log/errorlog
```

### Restart All Services

```bash
# Restart PM2 processes
pm2 restart all

# Restart Nginx
sudo systemctl restart nginx

# Restart SQL Server
sudo systemctl restart mssql-server

# Restart Docker (Superset)
docker-compose restart
```

---

## Security Checklist

- [ ] Change default passwords (sa, admin, azureuser)
- [ ] Configure firewall rules di Azure NSG
- [ ] Enable SQL Server authentication with strong passwords
- [ ] Use environment variables untuk secrets
- [ ] Enable HTTPS dengan SSL certificate
- [ ] Regular backup database
- [ ] Update system packages regularly
- [ ] Monitor resource usage
- [ ] Setup log rotation
- [ ] Disable root SSH login

---

## Next Steps

1. **Customize untuk Data Mart Anda:**

   - Edit star schema sesuai domain
   - Tambah dimensions dan facts
   - Buat reports spesifik
   - Setup ETL DAGs

2. **Konfigurasi Advanced:**

   - Setup ADLS integration (jika pakai Azure Data Lake)
   - Configure email notifications
   - Setup monitoring dengan Azure Monitor
   - Implement caching strategy

3. **Production Hardening:**
   - Setup backup strategy
   - Configure high availability
   - Implement disaster recovery
   - Setup CI/CD pipeline

---

## Resources

- **SQL Server on Linux:** https://docs.microsoft.com/en-us/sql/linux/
- **Apache Airflow Docs:** https://airflow.apache.org/docs/
- **Apache Superset Docs:** https://superset.apache.org/docs/
- **Nginx Configuration:** https://nginx.org/en/docs/
- **PM2 Documentation:** https://pm2.keymetrics.io/docs/

---

**Selamat! VM Azure Anda sudah siap untuk Data Mart Portal! 🎉**

Jika ada error atau pertanyaan, cek troubleshooting section atau hubungi admin.
