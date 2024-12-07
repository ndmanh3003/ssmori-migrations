-- TODO: Thêm khu vực mới
CREATE OR ALTER PROC sp_CreateRegion  
	@name NVARCHAR(100) 
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'region_name', @unique = @name;

    -- Thêm khu vực mới
	INSERT INTO Region (name) VALUES (@name)
END;
GO

-- TODO: Cập nhật khu vực
CREATE OR ALTER PROC sp_UpdateRegion
	@regionId INT,
	@name NVARCHAR(100) 
AS
BEGIN
	EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
    EXEC dbo.sp_ValidateUnique @type = 'region_name', @unique = @name;

    -- Cập nhật khu vực
	UPDATE Region
	SET name = COALESCE(@name, name)
	WHERE id = @regionId
END;
GO 

-- TODO: Xóa khu vực
CREATE OR ALTER PROC sp_DeleteRegion
    @regionId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Đóng cửa chi nhánh trong khu vực
    DECLARE @branchId INT
    DECLARE cur CURSOR FOR 
        SELECT id FROM Branch WHERE region = @regionId
    OPEN cur
    FETCH NEXT FROM cur INTO @branchId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_CloseBranch @branchId
        FETCH NEXT FROM cur INTO @branchId
    END
    CLOSE cur
    DEALLOCATE cur

    -- Xóa khu vực
    DELETE FROM Region WHERE id = @regionId
END;
