USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CloseCustomerCard
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    UPDATE Card
    SET isClosed = 1
    WHERE customer = @customerId
END
GO

CREATE OR ALTER PROCEDURE sp_CreateCustomerCard
    @branchId INT,
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Close existing card
    EXEC dbo.sp_CloseCustomerCard @customerId = @customerId

    -- Create new card
    INSERT INTO Card (issueAt, isClosed, branch, customer)
    VALUES (GETDATE(), 0, @branchId, @customerId)
END
GO

CREATE OR ALTER PROCEDURE sp_CreateCustomer
    @name NVARCHAR(100),
    @phone VARCHAR(15),
    @email VARCHAR(100),
    @gender CHAR(1)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email

    -- Create new customer
    INSERT INTO Customer (name, phone, email, gender, type, point, upgradeAt)
    VALUES (@name, @phone, @email, @gender, 'M', 0, GETDATE())
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateCustomer
    @customerId INT,              
    @name NVARCHAR(100) = NULL,   
    @email VARCHAR(100) = NULL,   
    @gender CHAR(1) = NULL        
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email

    -- Update customer
    UPDATE Customer
    SET name = COALESCE(@name, name),
        email = COALESCE(@email, email),
        gender = COALESCE(@gender, gender)
    WHERE id = @customerId;
END
GO