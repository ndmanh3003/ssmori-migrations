USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_Validate
    @type NVARCHAR(50),
    @id1 INT = NULL,
    @id2 INT = NULL,
    @id3 INT = NULL
AS
BEGIN

    -- * Relate to system
    IF @type = 'branch' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1 AND isDeleted = 0)
        THROW 50000, 'ERR_NO_BRANCH', 1;

    IF @type = 'branch_dish' AND NOT EXISTS (SELECT 1 FROM BranchDish WHERE branch = @id1 AND dish = @id2)
        THROW 50000, 'ERR_NO_BRANCH_DISH', 1;

    IF @type = 'region_dish' AND NOT EXISTS (SELECT 1 FROM RegionDish WHERE region = @id1 AND dish = @id2)
        THROW 50000, 'ERR_NO_REGION_DISH', 1;

    IF @type = 'branch_dish_served'
        BEGIN
            EXEC dbo.sp_Validate @type = 'branch_dish', @id1 = @id1, @id2 = @id2

            DECLARE @region1 INT;
            SELECT @region1 = region FROM Branch WHERE id = @id1;
            
            EXEC dbo.sp_Validate @type = 'region_dish', @id1 = @region1, @id2 = @id2;
        END;

    IF @type = 'branch_dish_shipping_served'
        BEGIN
            EXEC dbo.sp_Validate @type = 'branch_dish', @id1 = @id1, @id2 = @id2

            DECLARE @region2 INT;
            SELECT @region2 = region FROM Branch WHERE id = @id1;
            
            EXEC dbo.sp_Validate @type = 'region_dish', @id1 = @region2, @id2 = @id2;

            EXEC dbo.sp_Validate @type = 'branch_shipping', @id1 = @id1
            EXEC dbo.sp_Validate @type = 'dish_shipping', @id1 = @id2
        END;
    
    IF @type = 'branch_shipping' AND NOT EXISTS (SELECT 1 FROM Branch WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_CANT_SHIP', 1;

    IF @type = 'region_has_branch' AND NOT EXISTS (SELECT 1 FROM Branch WHERE region = @id1)
        THROW 50000, 'ERR_REGION_HAS_BRANCH', 1;

    IF @type = 'region' AND NOT EXISTS (SELECT 1 FROM Region WHERE id = @id1)
        THROW 50000, 'ERR_NO_REGION', 1;

    -- * Relate to customer
    IF @type = 'customer' AND NOT EXISTS (SELECT 1 FROM Customer WHERE id = @id1)
        THROW 50000, 'ERR_NO_CUSTOMER', 1;

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


    -- * Relate to menu
    IF @type = 'dish' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND isDeleted = 0)
        THROW 50000, 'ERR_NO_DISH', 1;

    IF @type = 'dish_is_combo' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND isCombo = 1)
        THROW 50000, 'ERR_NO_COMBO', 1;

    IF @type = 'dish_no_combo' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND isCombo = 0)
        THROW 50000, 'ERR_NOT_DISH', 1;

    IF @type = 'dish_shipping' AND NOT EXISTS (SELECT 1 FROM Dish WHERE id = @id1 AND canShip = 1)
        THROW 50000, 'ERR_DISH_CANT_SHIP', 1;

    IF @type = 'category' AND NOT EXISTS (SELECT 1 FROM Category WHERE id = @id1)
        THROW 50000, 'ERR_NO_CATEGORY', 1;

END;
GO