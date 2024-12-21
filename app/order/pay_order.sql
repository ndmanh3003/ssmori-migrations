USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_PayOrder
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'issued'

    -- Get invoice total and branch
    DECLARE @total DECIMAL(10,2), @branchId INT
    SELECT @total = totalPayment, @branchId = branch FROM Invoice WHERE id = @invoiceId
    
    -- Update statics revenue date
    MERGE StaticsRevenueDate AS target
    USING (SELECT @branchId as branch, CAST(GETDATE() AS DATE) as date) AS source
    ON target.branch = source.branch AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            totalInvoice = totalInvoice + 1,
            totalValue = totalValue + @total
    WHEN NOT MATCHED THEN
        INSERT (branch, date, totalInvoice, totalValue)
        VALUES (@branchId, CAST(GETDATE() AS DATE), 1, @total);

    -- Update statics dish month
    MERGE StaticsDishMonth AS target
    USING (
        SELECT 
            @branchId as branch, 
            DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as date,
            dish, 
            SUM(quantity) as totalQuantity
        FROM InvoiceDetail
        WHERE invoice = @invoiceId
        GROUP BY dish
    ) AS source
    ON target.branch = source.branch AND target.date = source.date AND target.dish = source.dish
    WHEN MATCHED THEN
        UPDATE SET 
            totalDish = totalQuantity + source.totalQuantity
    WHEN NOT MATCHED THEN
        INSERT (branch, date, dish, totalDish)
        VALUES (source.branch, source.date, source.dish, source.totalQuantity);

    -- Update customer point
    EXEC dbo.sp_UpdateCustomerPoint @invoiceId

    -- Update invoice status
    UPDATE Invoice SET status = 'paid' WHERE id = @invoiceId
END
GO
