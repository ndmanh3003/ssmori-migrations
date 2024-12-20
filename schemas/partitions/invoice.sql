USE SSMORI
GO

-- Tạo Partition Function phân chia theo năm từ 2022 trở đi
CREATE PARTITION FUNCTION pfInvoiceDate(DATETIME)
AS RANGE RIGHT FOR VALUES ('2023-01-01', '2024-01-01', '2025-01-01', '2026-01-01')
GO

-- Tạo Partition Scheme gắn vào nhóm file mặc định [PRIMARY]
CREATE PARTITION SCHEME psInvoiceDate
AS PARTITION pfInvoiceDate TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO

-- Tạo unique clustered index mới và ánh xạ Partition Scheme
CREATE UNIQUE NONCLUSTERED INDEX IX_Invoice_Clustered
ON Invoice (id, orderAt)
ON psInvoiceDate(orderAt);
GO


-- -- Kiểm tra thông tin partition của bảng
-- SELECT 
--     t.name AS TableName,
--     i.name AS IndexName,
--     ps.name AS PartitionScheme,
--     pf.name AS PartitionFunction,
--     p.partition_id,
--     p.partition_number,
--     p.rows
-- FROM 
--     sys.partitions p
-- INNER JOIN 
--     sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
-- INNER JOIN 
--     sys.tables t ON p.object_id = t.object_id
-- LEFT JOIN 
--     sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
-- LEFT JOIN 
--     sys.partition_functions pf ON ps.function_id = pf.function_id
-- WHERE 
--     t.name = 'Invoice'
-- ORDER BY 
--     p.partition_number;

-- -- Kiểm tra dữ liệu trong từng phân vùng
-- SELECT 
--     id,
--     orderAt,
--     $PARTITION.pfInvoiceDate(orderAt) AS PartitionNumber
-- FROM 
--     Invoice
-- ORDER BY 
--     PartitionNumber;

-- -- Thống kê chỉ mục phân vùng
-- DBCC SHOW_STATISTICS ('Invoice', 'IX_Invoice_Clustered');
