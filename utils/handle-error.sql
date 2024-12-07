USE SSMORI
GO

-- TODO: Kiểm tra sự tồn tại của các bản ghi
CREATE OR ALTER PROCEDURE sp_Validate
    @type NVARCHAR(50),
    @id1 INT,
    @id2 INT = NULL,
    @id3 INT = NULL
AS
BEGIN
    IF @type = 'branch' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1)
        THROW 50000, 'ERR_NO_BRANCH', 1;

    IF @type = 'customer' AND NOT EXISTS (SELECT 1 FROM Customer WHERE id = @id1)
        THROW 50000, 'ERR_NO_CUSTOMER', 1;

    IF @type = 'invoice' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1)
        THROW 50000, 'ERR_NO_INVOICE', 1;

    IF @type = 'branch_shipping' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_CANT_SHIP', 1;

    IF @type = 'invoice_online' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1 AND type = 'O')
        THROW 50000, 'ERR_NOT_ONLINE', 1;

    IF @type = 'invoice_reserve' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1 AND type = 'R')
        THROW 50000, 'ERR_NO_RESERVE', 1;

    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISH', 1;

    IF @type = 'dish_shipping' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_DISH_CANT_SHIP', 1;

    IF @type = 'branch_dish' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2)
        THROW 50000, 'ERR_NO_BRANCH_DISH', 1;

    IF @type = 'branch_dish_served' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2 AND isServed = 1)
        THROW 50000, 'ERR_DISH_NOT_SERVED', 1;
    
    IF @type = 'online_has_dish' AND NOT EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @id1)
        IF EXISTS (SELECT 1 FROM InvoiceOnline WHERE invoice = @id1)
            THROW 50000, 'ERR_NO_ONLINE_DISH', 1;
    
    IF @type = 'no_review' AND EXISTS (SELECT 1 FROM Review WHERE invoice = @id1)
        THROW 50000, 'ERR_REVIEWED', 1;

    IF @type = 'table_empty' AND EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice IS NOT NULL)
        THROW 50000, 'ERR_TABLE_NOT_EMPTY', 1;

    IF @type = 'table_invoice' AND NOT EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice = @id3)
        THROW 50000, 'ERR_TABLE_INVOICE_MISMATCH', 1;

    IF @type = 'employee' AND NOT EXISTS (SELECT 1 FROM Employee WHERE id = @id1)
        THROW 50000, 'ERR_NO_EMPLOYEE', 1;

    IF @type = 'card' AND NOT EXISTS (SELECT 1 FROM Card WHERE id = @id1)
        THROW 50000, 'ERR_NO_CARD', 1;

    IF @type = 'category' AND NOT EXISTS (SELECT 1 FROM Category WHERE id = @id1)
        THROW 50000, 'ERR_NO_CATEGORY', 1;

    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISH', 1;
END;
GO

-- TODO: Kiểm tra thời gian đặt phải là thời gian trong tương lai
CREATE OR ALTER PROCEDURE sp_CheckFutureTime
    @time DATETIME
AS
BEGIN
    IF @time <= GETDATE()
        THROW 50000, 'ERR_INVALID_TIME', 1;
END;
GO

-- TODO: Kiểm tra trạng thái của hóa đơn
CREATE OR ALTER PROCEDURE sp_CheckInvoiceStatus
    @id INT,
    @status NVARCHAR(15),
    @other NVARCHAR(15) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id AND status = @status AND (@other IS NULL OR type = @other))
        THROW 50000, 'ERR_INVALID_STATUS', 1;
END;
GO

-- TODO: Kiểm tra điều kiện áp dụng khuyến mãi
CREATE OR ALTER PROCEDURE sp_CheckDiscountCondition
    @discountType TINYINT,
    @total DECIMAL(10, 0),
    @shipCost DECIMAL(10, 0),
    @minApply DECIMAL(10, 0)
AS
BEGIN
    IF @discountType IN (0, 1) AND @total < @minApply
        THROW 50000, 'ERR_NOT_REACH_MINIMUM', 1;
    
    IF @discountType IN (2, 3) AND @shipCost < @minApply
        THROW 50000, 'ERR_NOT_REACH_MINIMUM', 1;
END;
GO

-- TODO: Kiểm tra đã tồn tại của thuộc tính unique
CREATE OR ALTER PROCEDURE sp_ValidateUnique
    @type NVARCHAR(50),
    @unique NVARCHAR(100)
AS
BEGIN
    IF @unique IS NULL 
        RETURN

    IF @type = 'customer_cid' AND EXISTS (SELECT 1 FROM Customer WHERE cid = @unique)
        THROW 50000, 'ERR_EXISTS_CID', 1

    IF @type = 'customer_phone' AND EXISTS (SELECT 1 FROM Customer WHERE phone = @unique)
        THROW 50000, 'ERR_EXISTS_CUSTOMER_PHONE', 1

    IF @type = 'customer_email' AND EXISTS (SELECT 1 FROM Customer WHERE email = @unique)
        THROW 50000, 'ERR_EXISTS_EMAIL', 1

    IF @type = 'category_nameVN' AND EXISTS (SELECT 1 FROM Category WHERE nameVN = @unique)
        THROW 50000, 'ERR_EXISTS_CATEGORY_NAMEVN', 1

    IF @type = 'category_nameJP' AND EXISTS (SELECT 1 FROM Category WHERE nameJP = @unique)
        THROW 50000, 'ERR_EXISTS_CATEGORY_NAMEJP', 1

    IF @type = 'dish_nameVN' AND EXISTS (SELECT 1 FROM Dish WHERE nameVN = @unique)
        THROW 50000, 'ERR_EXISTS_DISH_NAMEVN', 1

    IF @type = 'dish_nameJP' AND EXISTS (SELECT 1 FROM Dish WHERE nameJP = @unique)
        THROW 50000, 'ERR_EXISTS_DISH_NAMEJP', 1
END
GO


CREATE OR ALTER PROCEDURE sp_ValidateDishOrCombo
    @id INT,
    @isCombo BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id)
        THROW 50000, 'ERR_NO_DISH', 1

    IF NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id AND isCombo = @isCombo)
    BEGIN
        IF @isCombo = 1
            THROW 50000, 'ERR_NOT_REAL_COMBO', 1
        ELSE
            THROW 50000, 'ERR_NOT_REAL_MENU_ITEM', 1
    END
END
GO
