USE SSMORI
GO

-- TODO: Tạo đơn hàng online
CREATE OR ALTER PROCEDURE sp_CreateOnlineOrder
    @phone VARCHAR(15),
    @address NVARCHAR(255),
    @distanceKm INT,
    @branchId INT,
    @customerId INT = NULL,
    @invoiceId INT OUTPUT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch_shipping', @id1 = @branchId
    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Tính phí ship và tạo invoice mới
    DECLARE @shipCost DECIMAL(10,2) 
    SET @shipCost = dbo.fn_CalculateShipCost(@distanceKm)

    INSERT INTO Invoice (status, orderAt, customer, branch, type, shipCost)
    VALUES (0, GETDATE(), @customerId, @branchId, 'O', @shipCost)

    SET @invoiceId = SCOPE_IDENTITY()

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId

    -- Tạo thông tin giao hàng
    INSERT INTO InvoiceOnline (invoice, phone, address, distanceKm)
    VALUES (@invoiceId, @phone, @address, @distanceKm)
END
GO

-- TODO: Cập nhật thông tin đơn hàng online
CREATE OR ALTER PROCEDURE sp_UpdateOnlineOrder
    @invoiceId INT,
    @phone VARCHAR(15) = NULL,
    @address NVARCHAR(255) = NULL,
    @distanceKm INT = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice_online', @id1 = @invoiceId

    -- Cập nhật thông tin giao hàng
    UPDATE InvoiceOnline
    SET phone = COALESCE(@phone, phone),
        address = COALESCE(@address, address),
        distanceKm = COALESCE(@distanceKm, distanceKm)
    WHERE invoice = @invoiceId

    -- Cập nhật phí ship nếu có thay đổi khoảng cách
    IF @distanceKm IS NOT NULL
    BEGIN
        DECLARE @shipCost DECIMAL(10,2)
        SET @shipCost = dbo.fn_CalculateShipCost(@distanceKm)

        UPDATE Invoice 
        SET shipCost = @shipCost
        WHERE id = @invoiceId

        EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
    END
END
GO