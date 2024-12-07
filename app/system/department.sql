USE SSMORI
GO

-- TODO: Thêm phòng ban mới
CREATE OR ALTER PROC sp_CreateDepartment  
    @name NVARCHAR(100),
    @salary DECIMAL(18, 2)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'department_name', @unique = @name

    INSERT INTO Department (name, salary)
    VALUES (@name, @salary)
END;
GO 

-- TODO: Cập nhật phòng ban
CREATE OR ALTER PROC sp_UpdateDepartment  
    @departmentId INT,
    @name NVARCHAR(100) = NULL,
    @salary DECIMAL(18, 2) = NULL
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'department_name', @unique = @name
    EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    UPDATE Department
    SET name = COALESCE(@name, name),
        salary = COALESCE(@salary, salary)
    WHERE id = @departmentId
END;
GO

-- TODO: Xóa phòng ban
CREATE OR ALTER PROC sp_DeleteDepartment  
    @departmentId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'department', @id1 = @departmentId

    -- Thôi việc nhân viên trong phòng ban
    DECLARE @employeeId INT
    DECLARE cur CURSOR FOR 
        SELECT id FROM Employee WHERE department = @departmentId
    OPEN cur
    FETCH NEXT FROM cur INTO @employeeId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_LayOffEmployee @employeeId
        FETCH NEXT FROM cur INTO @employeeId
    END
    CLOSE cur
    DEALLOCATE cur

    -- Xóa phòng ban
    DELETE FROM Department WHERE id = @departmentId
END;
GO
