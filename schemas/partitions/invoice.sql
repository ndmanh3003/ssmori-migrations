USE MASTER
GO

-- Xóa cơ sở dữ liệu nếu đã tồn tại
IF DB_ID('SSMORI') IS NOT NULL
    DROP DATABASE SSMORI;
GO

-- Tạo cơ sở dữ liệu mới
CREATE DATABASE SSMORI
GO 

USE SSMORI
GO

-- Tạo Partition Function dựa trên ngày
CREATE PARTITION FUNCTION pfInvoiceDate(DATETIME)
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2023-07-01', '2024-01-01')
GO

-- Tạo Partition Scheme gắn vào nhóm file mặc định [PRIMARY]
CREATE PARTITION SCHEME psInvoiceDate
AS PARTITION pfInvoiceDate TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO


