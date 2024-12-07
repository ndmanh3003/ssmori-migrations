-- TODO: Kiểm tra sự tồn tại của các bản ghi
CREATE OR ALTER PROCEDURE sp_Validate
    @type NVARCHAR(50),
    @id1 INT,
    @id2 INT = NULL,
    @id3 INT = NULL
AS
BEGIN

    -- * Relate to system
    IF @type = 'branch' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1)
        THROW 50000, 'ERR_NO_BRANCH', 1;

    IF @type = 'branch_dish' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2)
        THROW 50000, 'ERR_NO_BRANCH_DISH', 1;

    IF @type = 'branch_dish_served' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2 AND isServed = 1)
        THROW 50000, 'ERR_DISH_NOT_SERVED', 1;
    
    IF @type = 'branch_shipping' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_CANT_SHIP', 1;

    IF @type = 'employee' AND NOT EXISTS (SELECT 1 FROM Employee WHERE id = @id1)
        THROW 50000, 'ERR_NO_EMPLOYEE', 1;

    IF @type = 'region_has_branch' AND NOT EXISTS (SELECT 1 FROM Branch WHERE region = @id1)
        THROW 50000, 'ERR_REGION_HAS_BRANCH', 1;

    IF @type = 'region' AND NOT EXISTS (SELECT 1 FROM Region WHERE id = @id1)
        THROW 50000, 'ERR_NO_REGION', 1;

    IF @type = 'department' AND NOT EXISTS (SELECT 1 FROM Department WHERE id = @id1)
        THROW 50000, 'ERR_NO_DEPARTMENT', 1;

    -- * Relate to customer
    IF @type = 'customer' AND NOT EXISTS (SELECT 1 FROM Customer WHERE id = @id1)
        THROW 50000, 'ERR_NO_CUSTOMER', 1;

    IF @type = 'card' AND NOT EXISTS (SELECT 1 FROM Card WHERE id = @id1)
        THROW 50000, 'ERR_NO_CARD', 1;

    -- * Relate to invoice
    IF @type = 'invoice' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1)
        THROW 50000, 'ERR_NO_INVOICE', 1;

    IF @type = 'invoice_online' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1 AND type = 'O')
        THROW 50000, 'ERR_NOT_ONLINE', 1;

    IF @type = 'invoice_reserve' AND NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id1 AND type = 'R')
        THROW 50000, 'ERR_NO_RESERVE', 1;
        
    IF @type = 'online_has_dish' AND NOT EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @id1)
        IF EXISTS (SELECT 1 FROM InvoiceOnline WHERE invoice = @id1)
            THROW 50000, 'ERR_NO_ONLINE_DISH', 1;
    
    IF @type = 'no_review' AND EXISTS (SELECT 1 FROM Review WHERE invoice = @id1)
        THROW 50000, 'ERR_REVIEWED', 1;
    
    IF @type = 'table_empty' AND EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice IS NOT NULL)
        THROW 50000, 'ERR_TABLE_NOT_EMPTY', 1;

    IF @type = 'table_invoice' AND NOT EXISTS (SELECT 1 FROM BranchTable WHERE branch = @id1 AND tbl = @id2 AND invoice = @id3)
        THROW 50000, 'ERR_TABLE_INVOICE_MISMATCH', 1;

    -- * Relate to menu
    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISH', 1;

    IF @type = 'dish_is_combo' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND isCombo = 1)
        THROW 50000, 'ERR_NO_COMBO', 1;

    IF @type = 'dish_no_combo' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND isCombo = 0)
        THROW 50000, 'ERR_NOT_DISH', 1;

    IF @type = 'dish_shipping' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_DISH_CANT_SHIP', 1;

    IF @type = 'category' AND NOT EXISTS (SELECT 1 FROM Category WHERE id = @id1)
        THROW 50000, 'ERR_NO_CATEGORY', 1;

    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1)
        THROW 50000, 'ERR_NO_DISH', 1;

END;
GO