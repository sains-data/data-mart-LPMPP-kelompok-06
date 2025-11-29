-- 1. Create SQL Server Agent Job
USE msdb;
GO

-- Menambahkan Job Utama
EXEC sp_add_job
    @job_name = N'ETL_Daily_Load',
    @enabled = 1,
    @description = N'Daily ETL load for Data Mart';
GO

-- 2. Menambahkan Langkah (Step) pada Job
EXEC sp_add_jobstep
    @job_name = N'ETL_Daily_Load',
    @step_name = N'Execute Master ETL',
    @subsystem = N'TSQL',
    @command = N'EXEC dbo.usp_Master_ETL;',
    @database_name = N'DM_[UnitName]_DW',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- 3. Menambahkan Jadwal (Schedule)
EXEC sp_add_schedule
    @schedule_name = N'Daily at 2 AM',
    @freq_type = 4,    -- 4 = Daily
    @freq_interval = 1,
    @active_start_time = 020000; -- 02:00:00 AM
GO

-- 4. Menghubungkan Jadwal ke Job
EXEC sp_attach_schedule
    @job_name = N'ETL_Daily_Load',
    @schedule_name = N'Daily at 2 AM';
GO

-- 5. Menetapkan Server untuk menjalankan Job
EXEC sp_add_jobserver
    @job_name = N'ETL_Daily_Load';
GO