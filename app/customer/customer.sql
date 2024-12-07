-- TODO: Tạo thẻ khách hàng mới
CREATE OR ALTER PROCEDURE sp_CreateCustomerCard
    @employeeId INT,
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Đóng thẻ cũ của khách hàng (nếu có)
    EXEC dbo.sp_CloseCustomerCard @customerId = @customerId

    -- Tạo thẻ cho khách hàng
    INSERT INTO Card (issueAt, isClosed, employee, customer)
    VALUES (GETDATE(), 0, @employeeId, @customerId)
END
GO

-- TODO: Đóng thẻ khách hàng
CREATE OR ALTER PROCEDURE sp_CloseCustomerCard
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Đóng thẻ của khách hàng
    UPDATE Card
    SET isClosed = 1
    WHERE customer = @customerId
END
GO

-- TODO: Thêm khách hàng mới
CREATE OR ALTER PROCEDURE sp_CreateCustomer
    @name NVARCHAR(100),
    @cid NVARCHAR(20),
    @phone VARCHAR(15),
    @email VARCHAR(100),
    @gender CHAR(1),
    @employeeId INT
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'customer_cid', @unique = @cid
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Thêm khách hàng mới
    INSERT INTO Customer (name, cid, phone, email, gender, type, point, upgradeAt)
    VALUES (@name, @cid, @phone, @email, @gender, 'M', 0, GETDATE())
END
GO

-- TODO: Cập nhật thông tin khách hàng
CREATE OR ALTER PROCEDURE sp_UpdateCustomer
    @customerId INT,              
    @name NVARCHAR(100) = NULL,   
    @cid NVARCHAR(20) = NULL,     
    @phone VARCHAR(15) = NULL,    
    @email VARCHAR(100) = NULL,   
    @gender CHAR(1) = NULL        
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId;
    EXEC dbo.sp_ValidateUnique @type = 'customer_cid', @unique = @cid;
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone;
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email;

    -- Cập nhật thông tin khách hàng
    UPDATE Customer
    SET name = COALESCE(@name, name),
        cid = COALESCE(@cid, cid),
        phone = COALESCE(@phone, phone),
        email = COALESCE(@email, email),
        gender = COALESCE(@gender, gender)
    WHERE id = @customerId;
END
GO
