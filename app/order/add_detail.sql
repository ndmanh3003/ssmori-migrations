USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_AddDetail
    @invoiceId INT,
    @dishId INT,
    @quantity INT
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'draft'
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId
    
    -- Get type and branchId
    DECLARE @type CHAR(1), @branchId INT
    SELECT @type = type, @branchId = branch FROM Invoice WHERE id = @invoiceId
    
    IF @type = 'O'
        EXEC dbo.sp_Validate @type = 'branch_dish_shipping_served', @id1 = @branchId, @id2 = @dishId
    ELSE
        EXEC dbo.sp_Validate @type = 'branch_dish_served', @id1 = @branchId, @id2 = @dishId

    IF @quantity > 0 AND NOT EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @invoiceId AND dish = @dishId)
    BEGIN
       -- Get price
        DECLARE @price DECIMAL(10,2)
        SELECT @price = price FROM Dish WHERE id = @dishId

        -- Add dish into invoice
        INSERT INTO InvoiceDetail (invoice, dish, quantity, sum)
        VALUES (@invoiceId, @dishId, @quantity, @quantity * @price)

        -- Update total
        UPDATE Invoice SET total = total + @quantity * @price WHERE id = @invoiceId
    END
END
GO