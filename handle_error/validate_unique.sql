USE SSMORI
GO

-- TODO: Kiểm tra unique các trường trong các bảng
CREATE OR ALTER PROCEDURE sp_ValidateUnique
    @type NVARCHAR(50),
    @unique NVARCHAR(100)
AS
BEGIN
    IF @unique IS NULL 
        RETURN

    IF @type = 'customer_phone' AND EXISTS (SELECT 1 FROM Customer WHERE phone = @unique)
        THROW 50000, 'ERR_EXISTS_CUSTOMER_PHONE', 1

    IF @type = 'customer_email' AND EXISTS (SELECT 1 FROM Customer WHERE email = @unique)
        THROW 50000, 'ERR_EXISTS_EMAIL', 1

    IF @type = 'category_name' AND EXISTS (SELECT 1 FROM Category WHERE name = @unique)
        THROW 50000, 'ERR_EXISTS_CATEGORY_NAME', 1

    IF @type = 'dish_nameVN' AND EXISTS (SELECT 1 FROM Dish WHERE nameVN = @unique)
        THROW 50000, 'ERR_EXISTS_DISH_NAMEVN', 1

    IF @type = 'dish_nameEN' AND EXISTS (SELECT 1 FROM Dish WHERE nameEN = @unique)
        THROW 50000, 'ERR_EXISTS_DISH_NAMEEN', 1

    IF @type = 'branch_name' AND EXISTS (SELECT 1 FROM Branch WHERE name = @unique)
        THROW 50000, 'ERR_EXISTS_BRANCH_NAME', 1    

    IF @type = 'branch_address' AND EXISTS (SELECT 1 FROM Branch WHERE address = @unique)
        THROW 50000, 'ERR_EXISTS_BRANCH_ADDRESS', 1

    IF @type = 'branch_phone' AND EXISTS (SELECT 1 FROM Branch WHERE phone = @unique)
        THROW 50000, 'ERR_EXISTS_BRANCH_PHONE', 1

    IF @type = 'region_name' AND EXISTS (SELECT 1 FROM Region WHERE name = @unique)
        THROW 50000, 'ERR_EXISTS_REGION_NAME', 1
END
GO