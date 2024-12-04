USE SSMORI
GO

-- TODO: Tự động cập nhật thống kê doanh thu theo tháng
CREATE OR ALTER TRIGGER trg_StaticsRevenueDate_UpdateStaticsRevenueMonth
ON StaticsRevenueDate
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @branchId INT;
    DECLARE @date DATE;
    DECLARE @total DECIMAL(18, 0);

    SELECT @branchId = branch, @date = date, @total = totalValue FROM inserted;

	MERGE StaticsRevenueMonth AS target
	USING (
		SELECT 
			branch, 
			DATEFROMPARTS(YEAR(date), MONTH(date), 1) as date, 
			totalValue 
		FROM inserted
		) AS source
		ON target.branch = source.branch AND target.date = source.date
		WHEN MATCHED THEN
		UPDATE SET 
			totalInvoice = target.totalInvoice + 1,
			totalValue = target.totalvalue + source.totalValue
	WHEN NOT MATCHED THEN
		INSERT (branch, date, totalInvoice, totalValue)
		VALUES (source.branch, source.date, 1, source.totalValue);
END
GO