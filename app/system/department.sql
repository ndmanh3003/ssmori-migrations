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

    -- Thôi việc mọi nhân viên trong chi nhánh
    UPDATE Employee
    SET endAt = GETDATE()
    WHERE id = @departmentId
	-- thêm trigger nếu upd endAt bên Employee thì phải upd cả endAt bên WorkHistory

    -- Xóa department
    DELETE FROM Department WHERE id = @departmentId
END
GO  