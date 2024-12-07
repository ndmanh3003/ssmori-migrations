USE SSMORI
GO

-- TODO: Thêm/xóa/cập nhật món ăn trong hóa đơn
CREATE OR ALTER PROCEDURE sp_ManageOrderDetail
    @invoiceId INT,
    @dishId INT,
    @quantity INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId
    
    -- Lấy thông tin đơn hàng
    DECLARE @type CHAR(1), @branchId INT
    SELECT @type = type, @branchId = branch FROM Invoice WHERE id = @invoiceId
    
    IF @type = 'O'
        EXEC dbo.sp_Validate @type = 'dish_shipping', @id1 = @dishId
    EXEC dbo.sp_Validate @type = 'branch_dish_served', @id1 = @branchId, @id2 = @dishId

    -- Xử lý quantity
    IF @quantity = 0
    BEGIN
        -- Xóa món ăn khỏi đơn
        DELETE FROM InvoiceDetail
        WHERE invoice = @invoiceId AND dish = @dishId
    END
    ELSE
    BEGIN
        -- Lấy giá món ăn
        DECLARE @price DECIMAL(10,2)
        SELECT @price = price FROM Dish WHERE id = @dishId

        -- Thêm/cập nhật món ăn
        IF EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @invoiceId AND dish = @dishId)
        BEGIN
            UPDATE InvoiceDetail
            SET quantity = @quantity,
                sum = @quantity * @price
            WHERE invoice = @invoiceId AND dish = @dishId
        END
        ELSE
        BEGIN
            INSERT INTO InvoiceDetail (invoice, dish, quantity, sum)
            VALUES (@invoiceId, @dishId, @quantity, @quantity * @price)
        END
    END

    -- Cập nhật tổng tiền invoice
    UPDATE Invoice
    SET total = (SELECT ISNULL(SUM(sum), 0) FROM InvoiceDetail WHERE invoice = @invoiceId)
    WHERE id = @invoiceId

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
END
GO