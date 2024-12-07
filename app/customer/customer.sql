USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateCustomerCard
    @employeeId INT,
    @customerId INT
AS
BEGIN
    -- Kiểm tra sự tồn tại của nhân viên
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Kiểm tra sự tồn tại của khách hàng
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Không sử dụng sp_CloseCustomerCard !!!!!!!!!!!!!!
    UPDATE Card
    SET isClosed = 1
    WHERE customer = @customerId

    -- Tạo thẻ cho khách hàng
    INSERT INTO Card (issueAt, isClosed, employee, customer)
    VALUES (GETDATE(), 0, @employeeId, @customerId)

    -- Lấy ID thẻ vừa tạo
    DECLARE @cardId INT = SCOPE_IDENTITY()

    -- Trả về ID của thẻ vừa tạo
    RETURN @cardId
END
GO


CREATE OR ALTER PROCEDURE sp_CloseCustomerCard
    @cardId INT
AS
BEGIN
    -- Kiểm tra thẻ có tồn tại không
    EXEC dbo.sp_Validate @type = 'card', @id1 = @cardId

    -- Cập nhật trạng thái thẻ là "closed"
    UPDATE Card
    SET isClosed = 1
    WHERE id = @cardId

    -- Trả về thông báo đóng thành công
    RETURN 1
END
GO

CREATE OR ALTER PROCEDURE sp_CreateCustomer
    @name NVARCHAR(100),
    @cid NVARCHAR(20),
    @phone VARCHAR(15),
    @email VARCHAR(100),
    @gender CHAR(1), -- M: Male, F: Female, O: Other
    @upgradeAt DATE = NULL, -- Default to NULL if not provided
    @employeeId INT   -- ID của nhân viên tạo thẻ
AS
BEGIN
    -- Kiểm tra căn cước đã tồn tại trong hệ thống
    EXEC dbo.sp_ValidateUnique @type = 'customer_cid', @unique = @cid
 
    -- Kiểm tra số điện thoại đã tồn tại trong hệ thống
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone

    -- Kiểm tra email đã tồn tại trong hệ thống
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email
   
    
    IF(@upgradeAt IS NULL)
        SET @upgradeAt = GETDATE()

    -- Thêm khách hàng mới vào bảng Customer
    INSERT INTO Customer (name, cid, phone, email, gender, type, point, upgradeAt)
    VALUES (@name, @cid, @phone, @email, @gender, 'M', 0, @upgradeAt)

    -- Lấy ID khách hàng vừa tạo
    DECLARE @customerId INT = SCOPE_IDENTITY()

    RETURN EXEC sp_CreateCustomerCard @employeeId = @employeeId, @customerId = @customerId
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateCustomer
    @customerId INT,              
    @name NVARCHAR(100) = NULL,   
    @cid NVARCHAR(20) = NULL,     
    @phone VARCHAR(15) = NULL,    
    @email VARCHAR(100) = NULL,   
    @gender CHAR(1) = NULL        
AS
BEGIN
    -- Kiểm tra khách hàng có tồn tại
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId;

    -- Kiểm tra tính duy nhất của căn cước công dân
    EXEC dbo.sp_ValidateUnique @type = 'customer_cid', @unique = @cid;

    -- Kiểm tra tính duy nhất của số điện thoại
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone;

    -- Kiểm tra tính duy nhất của email
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email;

    -- Cập nhật thông tin khách hàng
    UPDATE Customer
    SET name = COALESCE(@name, name),
        cid = COALESCE(@cid, cid),
        phone = COALESCE(@phone, phone),
        email = COALESCE(@email, email),
        gender = COALESCE(@gender, gender)
    WHERE id = @customerId;

    -- Trả về thông báo thành công
    RETURN 1;
END
GO
