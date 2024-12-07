-- TODO: Xác nhận thanh toán hóa đơn
CREATE OR ALTER PROCEDURE sp_ConfirmPayment
    @invoiceId INT,
    @tbl INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'ready'

    -- Lấy thông tin invoice
    DECLARE @total DECIMAL(10,2), @branchId INT
    SELECT @total = totalPayment, @branchId = branch FROM Invoice WHERE id = @invoiceId
    
    EXEC dbo.sp_Validate @type = 'table_invoice', @id1 = @branchId, @id2 = @tbl, @id3 = @invoiceId

    -- Cập nhật thống kê doanh thu theo ngày
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

    -- Cập nhật thống kê món ăn theo tháng
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

    -- Cập nhật điểm khách hàng và hạng thẻ
    EXEC dbo.sp_UpdateCustomerPoint @invoiceId

    -- Cập nhật trạng thái hóa đơn
    UPDATE BranchTable SET invoice = NULL WHERE branch = @branchId AND tbl = @tbl
    UPDATE Invoice SET status = 'paid' WHERE id = @invoiceId
END
GO
