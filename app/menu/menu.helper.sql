USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_DeleteRelateToDish
    @dishId  INT
AS
BEGIN
    DELETE FROM BranchDish WHERE dish = @dishId
    DELETE FROM RegionDish WHERE dish = @dishId
    DELETE FROM CategoryDish WHERE dish = @dishId

    DECLARE @isCombo BIT
    SELECT @isCombo = isCombo FROM Dish WHERE id = @dishId;

    IF @isCombo = 1
        DELETE FROM ComboDish WHERE combo = @dishId
    ELSE 
        DELETE FROM ComboDish WHERE dish = @dishId
END
GO


CREATE OR ALTER PROCEDURE sp_AddDishToEntity
    @entityType NVARCHAR(50),
    @entityId INT, 
    @dishId INT 
AS
BEGIN
    EXEC dbo.sp_Validate @type = @entityType, @id1 = @entityId;
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    IF @entityType = 'combo'
    BEGIN
        EXEC dbo.sp_Validate @type = 'dish_is_combo', @id1 = @entityId;
        EXEC dbo.sp_Validate @type = 'dish_no_combo', @id1 = @dishId;
    END

    -- Map entity type to table name
    DECLARE @tableName NVARCHAR(50) = 
        CASE @entityType
            WHEN 'category' THEN 'CategoryDish'
            WHEN 'combo' THEN 'ComboDish'
            WHEN 'region' THEN 'RegionDish'
            WHEN 'branch' THEN 'BranchDish'
        END;

    -- Build dynamic SQL
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        IF NOT EXISTS (
            SELECT 1 
            FROM ' + QUOTENAME(@tableName) + N'
            WHERE ' + QUOTENAME(@entityType) + N' = @entityId AND dish = @dishId
        )
        BEGIN
            INSERT INTO ' + QUOTENAME(@tableName) + N' (' + QUOTENAME(@entityType) + N', dish)
            VALUES (@entityId, @dishId);
        END
    ';

    -- Execute dynamic SQL
    EXEC sp_executesql @sql, 
        N'@entityId INT, @dishId INT', 
        @entityId = @entityId, 
        @dishId = @dishId;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDishFromEntity
    @entityType NVARCHAR(50),
    @entityId INT,
    @dishId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = @entityType, @id1 = @entityId;
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    IF @entityType = 'combo'
    BEGIN
        EXEC dbo.sp_Validate @type = 'dish_is_combo', @id1 = @entityId;
        EXEC dbo.sp_Validate @type = 'dish_no_combo', @id1 = @dishId;
    END

    -- Map entity type to table name
    DECLARE @tableName NVARCHAR(50) = 
        CASE @entityType
            WHEN 'category' THEN 'CategoryDish'
            WHEN 'combo' THEN 'ComboDish'
            WHEN 'region' THEN 'RegionDish'
            WHEN 'branch' THEN 'BranchDish'
        END;

    -- Build dynamic SQL
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        DELETE FROM ' + QUOTENAME(@tableName) + N'
        WHERE ' + QUOTENAME(@entityType) + N' = @entityId AND dish = @dishId;
    ';

    -- Execute dynamic SQL
    EXEC sp_executesql @sql, 
        N'@entityId INT, @dishId INT', 
        @entityId = @entityId, 
        @dishId = @dishId;
END
GO
