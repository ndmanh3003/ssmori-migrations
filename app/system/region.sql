USE SSMORI
GO

CREATE OR ALTER PROC sp_CreateRegion  
	@name NVARCHAR(100) 
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'region_name', @unique = @name;

    -- Insert region
	INSERT INTO Region (name) VALUES (@name)
END;
GO

CREATE OR ALTER PROC sp_UpdateRegion
	@regionId INT,
	@name NVARCHAR(100) 
AS
BEGIN
	EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
    EXEC dbo.sp_ValidateUnique @type = 'region_name', @unique = @name;

    -- Update region
	UPDATE Region
	SET name = COALESCE(@name, name)
	WHERE id = @regionId
END;
GO 

CREATE OR ALTER PROC sp_DeleteRegion
    @regionId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Delete all branches in region
    DECLARE @branchId INT
    DECLARE cur CURSOR FOR 
        SELECT id FROM Branch WHERE region = @regionId
    OPEN cur
    FETCH NEXT FROM cur INTO @branchId
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_DeleteBranch @branchId
        FETCH NEXT FROM cur INTO @branchId
    END
    CLOSE cur
    DEALLOCATE cur

    -- Delete region
    DELETE FROM Region WHERE id = @regionId
END;
