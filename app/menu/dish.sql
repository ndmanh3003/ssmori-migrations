USE SSMORI
GO

-- TODO: Thêm món ăn
CREATE OR ALTER PROCEDURE sp_CreateDish
    @isCombo BIT = 0,          
    @nameVN NVARCHAR(100),     
    @nameEN NVARCHAR(100),   
    @price DECIMAL(10, 2),     
    @canShip BIT = 0,          
    @img NVARCHAR(255) = NULL  
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameVN', @unique = @nameVN;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameEN', @unique = @nameEN;

    -- Thêm món ăn mới vào bảng Dish
    INSERT INTO Dish (isCombo, nameVN, nameEN, price, canShip, img)
    VALUES (@isCombo, @nameVN, @nameEN, @price, @canShip, @img);
END
GO

-- TODO: Cập nhật thông tin món ăn
CREATE OR ALTER PROCEDURE sp_UpdateDish
    @dishId INT,           
    @nameVN NVARCHAR(100) = NULL,   
    @nameEN NVARCHAR(100) = NULL,  
    @price DECIMAL(10, 2) = NULL,     
    @canShip BIT = NULL,      
    @img NVARCHAR(255) = NULL 
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameVN', @unique = @nameVN;
    EXEC dbo.sp_ValidateUnique @type = 'dish_nameEN', @unique = @nameEN;

    -- Cập nhật thông tin món ăn
    UPDATE Dish
    SET 
        nameVN = COALESCE(@nameVN, nameVN),
        nameEN = COALESCE(@nameEN, nameEN),
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

    -- Xóa các table liên quan
    EXEC dbo.sp_DeleteRelateToDish @dishId = @dishId;

    -- Đánh dấu đã xóa món ăn
    UPDATE Dish
    SET isDeleted = 1
    WHERE id = @dishId;
END
GO