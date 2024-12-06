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
END
GO

CREATE OR ALTER PROC sp_UpdateBranch
    @branchId INT,
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
    -- Kiểm tra branch có tồn tại
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    -- Cập nhật thông tin branch
    UPDATE Branch
    SET name = @name,
        address = @address,
        openTime = @openTime,
        closeTime = @closeTime,
        phone = @phone,
        hasMotoPark = @hasMotoPark,
        hasCarPark = @hasCarPark,
        tableQuantity = @tableQuantity,
        floorQuantity = @floorQuantity,
        canShip = @canShip,
        region = @regionId
    WHERE id = @branchId

    -- Nếu có thay đổi tableQuantity hoặc floorQuantity, cập nhật BranchTable
    IF EXISTS (SELECT 1
               FROM Branch
               WHERE id = @branchId
               AND (tableQuantity != @tableQuantity OR floorQuantity != @floorQuantity))
    BEGIN
        DELETE FROM BranchTable WHERE branch = @branchId

        DECLARE @totalTables INT = 20 + @floorQuantity * @tableQuantity
        DECLARE @counter INT = 1

        WHILE @counter <= @totalTables
        BEGIN
            INSERT INTO BranchTable (branch, tbl)
            VALUES (@branchId, @counter)
            SET @counter = @counter + 1
        END
    END
END
GO

--var
CREATE OR ALTER PROC sp_DeleteBranch
    @branchId INT
AS
BEGIN
    -- Kiểm tra branch có tồn tại
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    -- Xóa branch
    UPDATE Branch
	SET isDeleted = 0
	WHERE id = @branchId

	DELETE FROM BranchTable 
	WHERE branch = @branchId

	DELETE FROM BranchDish
	WHERE branch = @branchId
END
GO