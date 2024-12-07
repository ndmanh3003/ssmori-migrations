-- TODO: Thêm nhân viên mới
CREATE OR ALTER PROC sp_CreateEmployee  
	@name NVARCHAR(100),
    @dob DATE,
    @gender	CHAR(1),
	@branchId INT,
    @departmentId INT
AS 
BEGIN
	EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
	EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    -- Tạo nhân viên
	INSERT INTO EMPLOYEE (name, dob, gender, startAt, branch, department)
	VALUES(@name, @dob, @gender, @startAt, @branchId, @departmentId)

	DECLARE @employeeId INT;
    SET @employeeId = SCOPE_IDENTITY();

    -- Cập nhật bảng lịch sử làm việc
    INSERT INTO WorkHistory (employee, department, startAt)
    VALUES (@employeeId, @departmentId, GETDATE())
END
GO

-- TODO: Cập nhật thông tin nhân viên
CREATE OR ALTER PROC sp_UpdateEmployee
    @employeeId INT,
    @name NVARCHAR(100) = NULL,
    @dob DATE = NULL,
    @gender	CHAR(1) = NULL,
    @branchId INT = NULL,
    @departmentId INT = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId
    IF @branchId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    IF @departmentId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    -- Cập nhật thông tin nhân viên
    UPDATE Employee
    SET name = COALESCE(@name, name),
        dob = COALESCE(@dob, dob),
        gender = COALESCE(@gender, gender),
        branch = COALESCE(@branchId, branch),
        department = COALESCE(@departmentId, department)
    WHERE id = @employeeId

    -- Cập nhật lich sử làm việc nếu có thay đổi chi nhánh
    IF @branchId IS NOT NULL
    BEGIN
        UPDATE WorkHistory 
        SET endAt = GETDATE()
        WHERE employee = @employeeId AND endAt IS NULL

        DECLARE @departmentId INT = (SELECT department FROM Employee WHERE id = @employeeId)
        INSERT INTO WorkHistory (employee, department, startAt)
        VALUES (@employeeId, @departmentId, GETDATE())
    END
END
GO

-- TODO: Thôi việc nhân viên
CREATE OR ALTER PROC sp_LayOffEmployee
    @employeeId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Thôi việc nhân viên
    UPDATE Employee
    SET endAt = GETDATE()
    WHERE id = @employeeId

    -- Cập nhật lịch sử làm việc
    UPDATE WorkHistory
    SET endAt = GETDATE()
    WHERE employee = @employeeId AND endAt IS NULL
END
