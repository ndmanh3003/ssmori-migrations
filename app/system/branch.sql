USE SSMORI
GO

-- TODO: Thêm chi nhánh mới
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
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
	EXEC dbo.sp_ValidateUnique @type = 'branch_name', @unique = @name
	EXEC dbo.sp_ValidateUnique @type = 'branch_address', @unique = @address
	EXEC dbo.sp_ValidateUnique @type = 'branch_phone', @unique = @phone

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

    -- Thêm món ăn của vùng vào chi nhánh
    EXEC dbo.sp_InitDishesInRegionToBranch @branchId = @branchId, @regionId = @regionId
END
GO

-- TODO: Cập nhật thông tin chi nhánh
CREATE OR ALTER PROC sp_UpdateBranch  
    @branchId INT,
    @name NVARCHAR(100) = NULL,
    @address NVARCHAR(255) = NULL,
    @openTime TIME = NULL,
    @closeTime TIME = NULL,
    @phone NVARCHAR(20) = NULL,
    @hasMotoPark BIT = NULL,
    @hasCarPark BIT = NULL,
    @tableQuantity INT = NULL,
    @floorQuantity INT = NULL,
    @canShip BIT = NULL,
    @regionId INT = NULL
AS
BEGIN
	EXEC dbo.sp_ValidateUnique @type = 'branch_name', @unique = @name
	EXEC dbo.sp_ValidateUnique @type = 'branch_address', @unique = @address
	EXEC dbo.sp_ValidateUnique @type = 'branch_phone', @unique = @phone
    IF @regionId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Cập nhật thông tin branch
    UPDATE Branch
    SET name = COALESCE(@name, name),
        address = COALESCE(@address, address),
        openTime = COALESCE(@openTime, openTime),
        closeTime = COALESCE(@closeTime, closeTime),
        phone = COALESCE(@phone, phone),
        hasMotoPark = COALESCE(@hasMotoPark, hasMotoPark),
        hasCarPark = COALESCE(@hasCarPark, hasCarPark),
        tableQuantity = COALESCE(@tableQuantity, tableQuantity),
        floorQuantity = COALESCE(@floorQuantity, floorQuantity),
        canShip = COALESCE(@canShip, canShip),
        region = COALESCE(@regionId, region)
    WHERE id = @branchId

    -- Nếu có thay đổi tableQuantity hoặc floorQuantity, cập nhật BranchTable
    IF @tableQuantity IS NOT NULL OR @floorQuantity IS NOT NULL
    BEGIN
        DECLARE @oldTableQty INT, @oldFloorQty INT
        SELECT @oldTableQty = tableQuantity, @oldFloorQty = floorQuantity
        FROM Branch
        WHERE id = @branchId

        IF @tableQuantity IS NULL
            SET @tableQuantity = @oldTableQty
        IF @floorQuantity IS NULL
            SET @floorQuantity = @oldFloorQty

        DECLARE @totalTables INT = 20 + @floorQuantity * @tableQuantity
        DECLARE @currentTables INT = 20 + @oldTableQty * @oldFloorQty
        DECLARE @counter INT = @currentTables + 1

        IF @totalTables > @currentTables
        BEGIN
            WHILE @counter <= @totalTables 
            BEGIN
                INSERT INTO BranchTable (branch, tbl)
                VALUES (@branchId, @counter)
                SET @counter = @counter + 1
            END
        END
        ELSE
        BEGIN
            DELETE FROM BranchTable
            WHERE branch = @branchId AND tbl > @totalTables
        END
    END

    -- Nếu có thay đổi regionId, đổi BranchDish theo Region   
    IF @regionId IS NOT NULL
    BEGIN
        DELETE FROM BranchDish WHERE Branch = @branchId
        EXEC dbo.sp_InitDishesInRegionToBranch @branchId = @branchId, @regionId = @regionId
     END
END
GO

-- TODO: Xóa chi nhánh
CREATE OR ALTER PROC sp_DeleteBranch  
    @branchId INT
AS
BEGIN
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    -- Xóa branch
    UPDATE Branch
	SET isDeleted = 1
	WHERE id = @branchId

	DELETE FROM BranchTable WHERE branch = @branchId
	DELETE FROM BranchDish WHERE branch = @branchId

    -- Thôi việc nhân viên trong chi nhánh
    DECLARE @employeeId INT
    DECLARE cur CURSOR FOR 
        SELECT id FROM Employee WHERE branch = @branchId
    OPEN cur
    FETCH NEXT FROM cur INTO @employeeId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_LayOffEmployee @employeeId
        FETCH NEXT FROM cur INTO @employeeId
    END
    CLOSE cur
    DEALLOCATE cur
END
GO