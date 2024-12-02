USE SSMORI
GO

-- ! Trigger tự động cập nhật tổng doanh thu theo tháng
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
    USING (SELECT @branchId as branch, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1) as date) AS source
    ON target.branch = source.branch AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            totalInvoice = totalInvoice + 1,
            totalValue = totalValue + @total
    WHEN NOT MATCHED THEN
        INSERT (branch, date, totalInvoice, totalValue)
        VALUES (@branchId, DATEFROMPARTS(YEAR(@date), MONTH(@date), 1), 1, @total);
END
GO
