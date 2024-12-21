USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateOnlineOrder
    @phone VARCHAR(15),
    @address NVARCHAR(255),
    @orderAt DATETIME = NULL,
    @distanceKm INT,
    @branchId INT,
    @customerId INT = NULL,
    @invoiceId INT OUTPUT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch_shipping', @id1 = @branchId
    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Calculate ship cost
    DECLARE @shipCost DECIMAL(10,2) 
    SET @shipCost = dbo.fn_CalculateShipCost(@distanceKm)

    INSERT INTO Invoice (orderAt, customer, branch, type, shipCost)
    VALUES (COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'O', @shipCost)

    SET @invoiceId = SCOPE_IDENTITY()

    -- Create online order
    INSERT INTO InvoiceOnline (invoice, phone, address, distanceKm)
    VALUES (@invoiceId, @phone, @address, @distanceKm)
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateOnlineOrder
    @invoiceId INT,
    @phone VARCHAR(15) = NULL,
    @address NVARCHAR(255) = NULL,
    @distanceKm INT = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice_online', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'draft'

    -- Update online order
    UPDATE InvoiceOnline
    SET phone = COALESCE(@phone, phone),
        address = COALESCE(@address, address),
        distanceKm = COALESCE(@distanceKm, distanceKm)
    WHERE invoice = @invoiceId

    -- Update ship cost
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