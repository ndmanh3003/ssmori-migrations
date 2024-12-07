-- TODO: Kiểm tra unique các trường trong các bảng
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