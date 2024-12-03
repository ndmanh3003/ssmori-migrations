USE SSMORI
GO

-- ! Kiểm tra sự tồn tại của các bản ghi
CREATE OR ALTER PROCEDURE sp_Validate
    @type NVARCHAR(50),
    @id1 INT,
    @id2 INT = NULL,
    @id3 INT = NULL fd
    dlưndknj
    mdưkndkwnkwnkdkndsnkdskn
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

    IF @type = 'invoice_online' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1 AND isOnline = 1)
        THROW 50000, 'ERR_NOT_ONLINE', 1;

    IF @type = 'invoice_reserve' AND NOT EXISTS (SELECT 1 FROM InvoiceReserve WHERE invoice = @id1)
        THROW 50000, 'ERR_NO_RESERVE', 1;

    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISH', 1;

    IF @type = 'dish_shipping' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_DISH_CANT_SHIP', 1;

    IF @type = 'branch_dish' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2)
        THROW 50000, 'ERR_NO_BRANCH_DISH', 1;

    IF @type = 'branch_dish_served' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2 AND isServed = 1)
        THROW 50000, 'ERR_DISH_NOT_SERVED', 1;

    IF @type = 'discount' AND NOT EXISTS (SELECT 1 FROM Discount WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISCOUNT', 1;
    
    IF @type = 'discount_active' AND NOT EXISTS (SELECT 1 FROM Discount WHERE id = @id1  AND startAt <= GETDATE() AND (endAt IS NULL OR endAt > GETDATE()))
        THROW 50000, 'ERR_DISCOUNT_NOT_ACTIVE', 1;

    IF @type = 'online_dish' AND NOT EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @id1)
        IF EXISTS (SELECT 1 FROM InvoiceOnline WHERE invoice = @id1)
            THROW 50000, 'ERR_NO_ONLINE_DISH', 1;
    
    IF @type = 'no_review' AND EXISTS (SELECT 1 FROM Review WHERE invoice = @id1)
        THROW 50000, 'ERR_REVIEWED', 1;

    IF @type = 'table_empty' AND EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice IS NOT NULL)
        THROW 50000, 'ERR_TABLE_NOT_EMPTY', 1;

    IF @type = 'table_invoice' AND NOT EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice = @id3)
        THROW 50000, 'ERR_TABLE_INVOICE_MISMATCH', 1;
END;
GO

-- ! Kiểm tra thời gian đặt phải là thời gian trong tương lai
CREATE OR ALTER PROCEDURE sp_CheckFutureTime
    @time DATETIME
AS
BEGIN
    IF @time <= GETDATE()
        THROW 50000, 'ERR_INVALID_TIME', 1;
END;
GO

-- ! Kiểm tra trạng thái của hóa đơn
CREATE OR ALTER PROCEDURE sp_CheckInvoiceStatus
    @id INT,
    @status INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id AND status = @status)
        THROW 50000, 'ERR_INVALID_STATUS', 1;
END;
GO

-- ! Kiểm tra điều kiện áp dụng khuyến mãi
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