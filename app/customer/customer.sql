USE SSMORI
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

-- TODO: Tạo thẻ khách hàng mới
CREATE OR ALTER PROCEDURE sp_CreateCustomerCard
    @branchId INT,
    @customerId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Đóng thẻ cũ của khách hàng (nếu có)
    EXEC dbo.sp_CloseCustomerCard @customerId = @customerId

    -- Tạo thẻ cho khách hàng
    INSERT INTO Card (issueAt, isClosed, branch, customer)
    VALUES (GETDATE(), 0, @branchId, @customerId)
END
GO

-- TODO: Thêm khách hàng mới
CREATE OR ALTER PROCEDURE sp_CreateCustomer
    @name NVARCHAR(100),
    @phone VARCHAR(15),
    @email VARCHAR(100),
    @gender CHAR(1)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'customer_phone', @unique = @phone
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email

    -- Thêm khách hàng mới
    INSERT INTO Customer (name, phone, email, gender, type, point, upgradeAt)
    VALUES (@name, @phone, @email, @gender, 'M', 0, GETDATE())
END
GO

-- TODO: Cập nhật thông tin khách hàng
CREATE OR ALTER PROCEDURE sp_UpdateCustomer
    @customerId INT,              
    @name NVARCHAR(100) = NULL,   
    @email VARCHAR(100) = NULL,   
    @gender CHAR(1) = NULL        
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId
    EXEC dbo.sp_ValidateUnique @type = 'customer_email', @unique = @email

    -- Cập nhật thông tin khách hàng
    UPDATE Customer
    SET name = COALESCE(@name, name),
        email = COALESCE(@email, email),
        gender = COALESCE(@gender, gender)
    WHERE id = @customerId;
END
GO



CREATE OR ALTER PROCEDURE sp_DownCustomersRank
AS
BEGIN
    -- Khai báo các biến để lưu trữ thông tin của khách hàng
    DECLARE @CustomerID INT,
            @CustomerType CHAR(1),
            @CustomerPoint INT,
            @UpgradeAt DATE;

    -- Khai báo cursor để duyệt qua khách hàng cần xuống hạng
    DECLARE CustomerCursor CURSOR FOR
        SELECT id, type, point, upgradeAt
        FROM Customer
        WHERE 
            DATEDIFF(DAY, upgradeAt, GETDATE()) > 365
            AND (
                (type = 'S' AND point < 50) OR 
                (type = 'G' AND point < 100)
            );

    -- Mở cursor
    OPEN CustomerCursor;

    -- Lặp qua từng khách hàng
    FETCH NEXT FROM CustomerCursor INTO @CustomerID, @CustomerType, @CustomerPoint, @UpgradeAt;

    -- Lặp cho đến khi hết tất cả khách hàng
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Cập nhật hạng và điểm tích lũy của khách hàng
        UPDATE Customer
        SET 
            type = CASE
                WHEN @CustomerType = 'S' THEN 'M'
                WHEN @CustomerType = 'G' THEN 'S'
            END,
            point = 0,
            upgradeAt = GETDATE()
        WHERE id = @CustomerID;

        -- Lấy khách hàng tiếp theo trong cursor
        FETCH NEXT FROM CustomerCursor INTO @CustomerID, @CustomerType, @CustomerPoint, @UpgradeAt;
    END

    -- Đóng cursor và giải phóng tài nguyên
    CLOSE CustomerCursor;
    DEALLOCATE CustomerCursor;
END;
GO

