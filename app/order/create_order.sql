USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateOnlineOrder
    @phone VARCHAR(15),
    @address NVARCHAR(255),
    @orderAt DATETIME = NULL,
    @distanceKm INT,
    @branchId INT,
    @customerId INT,
    @invoiceId INT OUTPUT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch_shipping', @id1 = @branchId
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Calculate ship cost
    DECLARE @shipCost DECIMAL(10,2) 
    SET @shipCost = dbo.fn_CalculateShipCost(@distanceKm)

    INSERT INTO Invoice (status, orderAt, customer, branch, type, shipCost)
    VALUES ('draft', COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'O', @shipCost)

    SET @invoiceId = SCOPE_IDENTITY()

    -- Create online order
    INSERT INTO InvoiceOnline (invoice, phone, address, distanceKm)
    VALUES (@invoiceId, @phone, @address, @distanceKm)
END
GO

CREATE OR ALTER PROCEDURE sp_CreateReserveOrder
    @branchId INT,
    @orderAt DATETIME = NULL,
	@guestCount INT,
    @bookingAt DATETIME,
    @phone VARCHAR(15),
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_CheckFutureTime @time = @bookingAt
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Create reserve order
    INSERT INTO Invoice (status, orderAt, customer, branch, type)
    VALUES ('submitted', COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'R')

    DECLARE @invoiceId INT
    SET @invoiceId = SCOPE_IDENTITY()

    INSERT INTO InvoiceReserve (invoice, guestCount, bookingAt, phone)
    VALUES (@invoiceId, @guestCount, @bookingAt, @phone)
END
GO

CREATE OR ALTER PROCEDURE sp_CreateOffOrder
    @invoiceId INT = NULL,
    @orderAt DATETIME = NULL,
    @customerId INT = NULL,
    @branchId INT = NULL,
    @outInvoiceId INT OUTPUT
AS
BEGIN
    IF @invoiceId IS NOT NULL
    BEGIN
        EXEC dbo.sp_Validate @type = 'invoice_reserve', @id1 = @invoiceId
        EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'

        -- Update invoice status
        UPDATE Invoice SET status = 'draft' WHERE id = @invoiceId

        SET @outInvoiceId = @invoiceId
        RETURN
    END

    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Serve order
    INSERT INTO Invoice (status, orderAt, customer, branch, type)
    VALUES ('draft', COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'W')

    SET @outInvoiceId = SCOPE_IDENTITY()
END
GO