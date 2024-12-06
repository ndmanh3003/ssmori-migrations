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
END
GO