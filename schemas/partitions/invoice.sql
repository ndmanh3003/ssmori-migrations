-- Tạo Partition Function phân chia theo năm từ 2022 trở đi
CREATE PARTITION FUNCTION pfInvoiceDate(DATETIME)
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2024-01-01', '2025-01-01', '2026-01-01')
GO

-- Tạo Partition Scheme gắn vào nhóm file mặc định [PRIMARY]
CREATE PARTITION SCHEME psInvoiceDate
AS PARTITION pfInvoiceDate TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO

-- Tạo unique clustered index mới và ánh xạ Partition Scheme
CREATE UNIQUE CLUSTERED INDEX IX_Invoice_Clustered
ON Invoice (InvoiceNumber, orderAt)
ON psInvoiceDate(orderAt);
GO
