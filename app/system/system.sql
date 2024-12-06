-- Cập nhật các hằng số trong hệ thống
CREATE OR ALTER PROCEDURE sp_UpdateSystemConstants
    @costPerKm DECIMAL(10, 2),
    @freeDistance INT,
    @phone NVARCHAR(15),
	@shipMemberDiscount INT,
	@shipSilverDiscount INT,
	@shipGoldDiscount INT,
	@dishMemberDiscount INT,
	@dishSilverDiscount INT,
	@dishGoldDiscount INT
AS
BEGIN
	DELETE FROM CONST
    INSERT INTO CONST VALUES(
		@costPerKm,
		@freeDistance,
		@phone,
		@shipMemberDiscount,
		@shipSilverDiscount,
		@shipGoldDiscount,
		@dishMemberDiscount ,
		@dishSilverDiscount ,
		@dishGoldDiscount
	)
END
GO

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
    DELETE FROM Branch WHERE id = @branchId;
END
GO
--====================================================================

CREATE OR ALTER PROC sp_CreateDepartment
    @name NVARCHAR(100),
    @salary DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Department (name, salary)
    VALUES (@name, @salary)
END;
GO 

CREATE OR ALTER PROC sp_UpdateDepartment
    @departmentId INT,
    @name NVARCHAR(100),
    @salary DECIMAL(18, 2)
AS
BEGIN
    -- Kiểm tra department có tồn tại
	EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    UPDATE Department
    SET name = @name,
        salary = @salary
    WHERE id = @departmentId
END
GO
  
CREATE OR ALTER PROC sp_DeleteDepartment
    @departmentId INT
AS
BEGIN
    -- Kiểm tra department có tồn tại
	EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    -- Thôi việc mọi nhân viên trong chi nhánh (thực ra bước này hơi vô nghĩa)
    UPDATE Employee
    SET endAt = GETDATE()
    WHERE id = @departmentId

    -- Xóa department
    DELETE FROM Department WHERE id = @departmentId
END
GO  

--====================================================================
CREATE OR ALTER PROC sp_CreateEmployee  
	@name NVARCHAR(100),
    @dob DATE,
    @gender	CHAR(1),
    @startAt DATE,
	@branch	INT,
    @department INT
	--@employeeId INT OUTPUT
AS 
BEGIN
	SET IDENTITY_INSERT Employee OFF
	-- Kiểm tra branch, department có tồn tại
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branch

	EXEC dbo.sp_Validate @type = 'department', @id1 = @department

	INSERT INTO EMPLOYEE (name, dob, gender, startAt, branch, department)
	VALUES(@name, @dob, @gender, @startAt, @branch, @department)

	--SET @employeeId = SCOPE_IDENTITY()
	-- Cập nhật workhistory
	DECLARE @employeeId INT;
    SET @employeeId = SCOPE_IDENTITY();

    -- Cập nhật bảng lịch sử làm việc (work history)
    INSERT INTO WorkHistory VALUES (@employeeId, @startAt, null, @branch)

	SET IDENTITY_INSERT Employee ON
END
GO

CREATE OR ALTER PROC sp_UpdateEmployee  
	@employeeId INT,
	@name NVARCHAR(100),
    @dob DATE,
    @gender	CHAR(1),
	@branch	INT,
    @department INT
AS 
BEGIN
	-- Kiểm tra employee, branch, department có tồn tại
	EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branch

	EXEC dbo.sp_Validate @type = 'department', @id1 = @department

	IF (@branch IS NOT NULL)
	BEGIN
		UPDATE EMPLOYEE 
		SET branch = COALESCE(@branch, branch)
		WHERE id = @employeeId
	END
		
	-- Cập nhật thông tin của employee
	UPDATE EMPLOYEE 
	SET name = COALESCE(@name, name),
		dob = COALESCE(@dob, dob), 
		gender = COALESCE(@gender, gender), 
		department = COALESCE(@name, department)
	WHERE id = @employeeId
END
GO

CREATE OR ALTER PROC sp_LayOffEmployee  
	@employeeId INT
AS 
BEGIN
	-- Kiểm tra employee có tồn tại
	EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

	-- Cập nhật thông tin của employee 
	UPDATE Employee 
	SET endAt = GETDATE()
	WHERE id = @employeeId

	UPDATE WorkHistory 
	SET endAt = GETDATE()
	WHERE employee = @employeeId
END
GO

--====================================================================
CREATE OR ALTER PROC sp_CreateRegion  
	@name NVARCHAR(100) 
AS
BEGIN
	SET IDENTITY_INSERT Region OFF

	INSERT INTO Region (name) VALUES (@name)

	SET IDENTITY_INSERT Region ON
END
GO

CREATE OR ALTER PROC sp_UpdateRegion
	@regionId INT,
	@name NVARCHAR(100) 
AS
BEGIN
	-- Kiểm tra	region có tồn tại
	EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

	UPDATE Region
	SET name = COALESCE(@name, name)
	WHERE id = @regionId
END
GO 

CREATE OR ALTER PROC sp_DeleteRegion
	@regionId INT
AS
BEGIN
	-- Kiểm tra	region có tồn tại
	EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

	-- Xóa region
	DELETE FROM Region
	WHERE id = @regionId
END
GO 