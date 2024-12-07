-- TODO: Tạo hóa đơn đặt bàn
CREATE OR ALTER PROCEDURE sp_CreateReserveOrder
    @branchId INT,
	@guestCount INT,
    @bookingAt DATETIME,
    @phone VARCHAR(15),
    @customerId INT = NULL,
    @invoiceId INT OUTPUT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_CheckFutureTime @time = @bookingAt
    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Tạo invoice mới
    INSERT INTO Invoice (status, orderAt, customer, branch, type)
    VALUES ('ordering', GETDATE(), @customerId, @branchId, 'R')

    SET @invoiceId = SCOPE_IDENTITY()

    -- Tạo thông tin đặt bàn
    INSERT INTO InvoiceReserve (invoice, guestCount, bookingAt, phone)
    VALUES (@invoiceId, @guestCount, @bookingAt, @phone)
END
GO

-- TODO: Cập nhật thông tin đặt bàn
CREATE OR ALTER PROCEDURE sp_UpdateReserveOrder
    @invoiceId INT,
    @guestCount INT = NULL,
    @bookingAt DATETIME = NULL,
    @phone VARCHAR(15) = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice_reserve', @id1 = @invoiceId
    IF @bookingAt IS NOT NULL 
        EXEC dbo.sp_CheckFutureTime @time = @bookingAt

    -- Cập nhật thông tin đặt bàn
    UPDATE InvoiceReserve
    SET guestCount = COALESCE(@guestCount, guestCount),
        bookingAt = COALESCE(@bookingAt, bookingAt),
        phone = COALESCE(@phone, phone)
    WHERE invoice = @invoiceId
END
GO