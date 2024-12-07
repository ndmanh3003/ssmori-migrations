CREATE OR ALTER PROC sp_CreateBranch 
    @name NVARCHAR(100),
    @address NVARCHAR(255),
    @openTime TIME,
    @closeTime TIME,
    @phone NVARCHAR(20),
    @hasMotoPark BIT,
    @hasCarPark BIT,
    @tableQuantity INT,
    @floorQuantity INT,
    @canShip BIT,
    @regionId INT
AS
BEGIN
	-- Kiểm tra unique
	EXEC dbo.sp_ValidateUnique @type = 'branch', @unique = @name

	EXEC dbo.sp_ValidateUnique @type = 'branch', @unique = @address

	EXEC dbo.sp_ValidateUnique @type = 'branch', @unique = @phone


    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId;
	
    -- Tạo branch
    INSERT INTO Branch (name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, tableQuantity, floorQuantity, canShip, region)
    VALUES (@name, @address, @openTime, @closeTime, @phone, @hasMotoPark, @hasCarPark, @tableQuantity, @floorQuantity, @canShip, @regionId)

    DECLARE @branchId INT = SCOPE_IDENTITY();

    -- Tạo records trong BranchTable
    DECLARE @totalTables INT = 20 + @floorQuantity * @tableQuantity
    DECLARE @counter INT = 1

    WHILE @counter <= @totalTables 
    BEGIN
        INSERT INTO BranchTable (branch, tbl)
        VALUES (@branchId, @counter)
        SET @counter = @counter + 1
    END

    DECLARE @branchInRegion INT
    SELECT TOP 1 @branchInRegion = id
    FROM Branch b
    WHERE b.region = @regionId AND b.isDeleted = 0 AND b.id != @branchId

    IF @branchInRegion = NULL
        RETURN

    INSERT INTO BranchDish (branch, dish, isServed)
    SELECT @branchId, bd.dish, 1
    FROM BranchDish bd
    WHERE bd.branch = @branchInRegion
END
GO


--CREATE OR ALTER PROC sp_UpdateBranch  
--CREATE OR ALTER PROC sp_DeleteBranch  
