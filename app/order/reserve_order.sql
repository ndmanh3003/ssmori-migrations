USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateReserveOrder
    @branchId INT,
    @orderAt DATETIME = NULL,
	@guestCount INT,
    @bookingAt DATETIME,
    @phone VARCHAR(15),
    @customerId INT = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_CheckFutureTime @time = @bookingAt
    IF @customerId IS NOT NULL
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
    @status NVARCHAR(15) = NULL,
    @customerId INT = NULL,
    @branchId INT = NULL
AS
BEGIN
    IF @invoiceId IS NOT NULL
    BEGIN
        EXEC dbo.sp_Validate @type = 'invoice_reserve', @id1 = @invoiceId
        EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'

        -- Update invoice status
        UPDATE Invoice SET status = 'draft' WHERE id = @invoiceId
        RETURN
    END

    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Serve order
    INSERT INTO Invoice (status, orderAt, customer, branch, type)
    VALUES ('draft', COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'W')
END
GO