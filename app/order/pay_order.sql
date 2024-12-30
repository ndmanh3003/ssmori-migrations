USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_PayOrder
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'

    -- Get invoice total payment, customerId and branch
    DECLARE @totalPayment DECIMAL(10,2), @branchId INT, @customerId INT, @orderAt DATETIME
    SELECT @totalPayment = totalPayment, @customerId = customer, @branchId = branch, @orderAt = orderAt FROM Invoice WHERE id = @invoiceId
    
    -- Update statics revenue date
    MERGE StaticsRevenueDate AS target
    USING (SELECT @branchId as branch, CAST(@orderAt AS DATE) as date) AS source
    ON target.branch = source.branch AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            totalInvoice = totalInvoice + 1,
            totalValue = totalValue + @totalPayment
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (branch, date, totalInvoice, totalValue)
        VALUES (@branchId, CAST(@orderAt AS DATE), 1, @totalPayment);

    -- Update statics dish month
    MERGE StaticsDishMonth AS target
    USING (
        SELECT 
            @branchId as branch, 
            DATEFROMPARTS(YEAR(@orderAt), MONTH(@orderAt), 1) as date,
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
    IF @customerId IS NOT NULL
        EXEC dbo.sp_UpdateCustomerPoint @customerId = @customerId, @totalPayment = @totalPayment, @orderAt = @orderAt

    -- Update invoice status
    UPDATE Invoice SET status = 'paid' WHERE id = @invoiceId
END
GO
