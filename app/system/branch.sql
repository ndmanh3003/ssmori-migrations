USE SSMORI
GO

CREATE OR ALTER PROC sp_CreateBranch 
    @name NVARCHAR(100),
    @address NVARCHAR(255),
    @img NVARCHAR(255) = NULL,
    @openTime TIME,
    @closeTime TIME,
    @phone NVARCHAR(20),
    @hasMotoPark BIT,
    @hasCarPark BIT,
    @canShip BIT,
    @regionId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
	EXEC dbo.sp_ValidateUnique @type = 'branch_name', @unique = @name
	EXEC dbo.sp_ValidateUnique @type = 'branch_address', @unique = @address
	EXEC dbo.sp_ValidateUnique @type = 'branch_phone', @unique = @phone

    -- Insert branch
    INSERT INTO Branch (name, address, img, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip, region)
    VALUES (@name, @address, @img, @openTime, @closeTime, @phone, @hasMotoPark, @hasCarPark, @canShip, @regionId)
END
GO

CREATE OR ALTER PROC sp_UpdateBranch  
    @branchId INT,
    @name NVARCHAR(100) = NULL,
    @address NVARCHAR(255) = NULL,
    @img NVARCHAR(255) = NULL,
    @openTime TIME = NULL,
    @closeTime TIME = NULL,
    @phone NVARCHAR(20) = NULL,
    @hasMotoPark BIT = NULL,
    @hasCarPark BIT = NULL,
    @canShip BIT = NULL,
    @regionId INT = NULL
AS
BEGIN
	EXEC dbo.sp_ValidateUnique @type = 'branch_name', @unique = @name
	EXEC dbo.sp_ValidateUnique @type = 'branch_address', @unique = @address
	EXEC dbo.sp_ValidateUnique @type = 'branch_phone', @unique = @phone
    IF @regionId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Update branch
    UPDATE Branch
    SET name = COALESCE(@name, name),
        address = COALESCE(@address, address),
        img = COALESCE(@img, img),
        openTime = COALESCE(@openTime, openTime),
        closeTime = COALESCE(@closeTime, closeTime),
        phone = COALESCE(@phone, phone),
        hasMotoPark = COALESCE(@hasMotoPark, hasMotoPark),
        hasCarPark = COALESCE(@hasCarPark, hasCarPark),
        canShip = COALESCE(@canShip, canShip),
        region = COALESCE(@regionId, region)
    WHERE id = @branchId
END
GO

CREATE OR ALTER PROC sp_DeleteBranch  
    @branchId INT
AS
BEGIN
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    DELETE FROM BranchDish WHERE branch = @branchId

    -- Delete branch
    UPDATE Branch
	SET isDeleted = 1
	WHERE id = @branchId
END
GO