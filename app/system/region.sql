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