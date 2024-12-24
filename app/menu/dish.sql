USE SSMORI
GO

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

    -- Add new dish
    INSERT INTO Dish (isCombo, nameVN, nameEN, price, canShip, img)
    VALUES (@isCombo, @nameVN, @nameEN, @price, @canShip, @img);
END
GO

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

    -- Update dish
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

CREATE OR ALTER PROCEDURE sp_DeleteDish
    @dishId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    -- Delete related data
    EXEC dbo.sp_DeleteRelateToDish @dishId = @dishId;

    -- Delete dish
    UPDATE Dish
    SET isDeleted = 1
    WHERE id = @dishId;
END
GO