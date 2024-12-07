-- TODO: Thêm món ăn
CREATE OR ALTER PROCEDURE sp_CreateDish
    @isCombo BIT = 0,          
    @nameVN NVARCHAR(100),     
    @nameJP NVARCHAR(100),     
    @description NVARCHAR(255),
    @price DECIMAL(10, 2),     
    @canShip BIT = 0,          
    @img NVARCHAR(255) = NULL  
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameVN', @unique = @nameVN;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameJP', @unique = @nameJP;

    -- Thêm món ăn mới vào bảng Dish
    INSERT INTO Dish (isCombo, nameVN, nameJP, description, price, canShip, img)
    VALUES (@isCombo, @nameVN, @nameJP, @description, @price, @canShip, @img);
END
GO

-- TODO: Cập nhật thông tin món ăn
CREATE OR ALTER PROCEDURE sp_UpdateDish
    @dishId INT,              
    @isCombo BIT = NULL,      
    @nameVN NVARCHAR(100) = NULL,   
    @nameJP NVARCHAR(100) = NULL,   
    @description NVARCHAR(255) = NULL, 
    @price DECIMAL(10, 2) = NULL,     
    @canShip BIT = NULL,      
    @img NVARCHAR(255) = NULL 
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameVN', @unique = @nameVN;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameJP', @unique = @nameJP;

    -- Cập nhật thông tin món ăn
    UPDATE Dish
    SET 
        isCombo = COALESCE(@isCombo, isCombo),
        nameVN = COALESCE(@nameVN, nameVN),
        nameJP = COALESCE(@nameJP, nameJP),
        description = COALESCE(@description, description),
        price = COALESCE(@price, price),
        canShip = COALESCE(@canShip, canShip),
        img = COALESCE(@img, img)
    WHERE id = @dishId;
END
GO

-- TODO: Xóa món ăn
CREATE OR ALTER PROCEDURE sp_DeleteDish
    @dishId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    -- TODO: Xóa các table liên quan

    -- Đánh dấu đã xóa món ăn
    UPDATE Dish
    SET isDeleted = 1
    WHERE id = @dishId;
END
GO