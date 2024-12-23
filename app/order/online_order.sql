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

    INSERT INTO Invoice (status, orderAt, customer, branch, type, shipCost)
    VALUES ('draft', COALESCE(@orderAt, GETDATE()), @customerId, @branchId, 'O', @shipCost)

    SET @invoiceId = SCOPE_IDENTITY()

    -- Create online order
    INSERT INTO InvoiceOnline (invoice, phone, address, distanceKm)
    VALUES (@invoiceId, @phone, @address, @distanceKm)
END
GO