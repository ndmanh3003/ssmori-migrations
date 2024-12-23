USE SSMORI
GO

-- TODO: Xóa món ăn liên quan
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


-- TODO: Thêm món ăn vào thực thể
CREATE OR ALTER PROCEDURE sp_AddDishToEntity
    @entityType NVARCHAR(50), -- Loại entity ('category', 'combo', 'region', 'branch')
    @entityId INT,            -- ID của entity
    @dishId INT               -- ID của dish
AS
BEGIN
    -- Validate entity và dish
    EXEC dbo.sp_Validate @type = @entityType, @id1 = @entityId;
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    -- Thêm validate bổ sung cho combo
    IF @entityType = 'combo'
    BEGIN
        EXEC dbo.sp_Validate @type = 'dish_is_combo', @id1 = @entityId;
        EXEC dbo.sp_Validate @type = 'dish_no_combo', @id1 = @dishId;
    END

    -- Xây dựng tên bảng dựa trên entityType
    DECLARE @tableName NVARCHAR(50) = 
        CASE @entityType
            WHEN 'category' THEN 'CategoryDish'
            WHEN 'combo' THEN 'ComboDish'
            WHEN 'region' THEN 'RegionDish'
            WHEN 'branch' THEN 'BranchDish'
        END;

    -- Xây dựng SQL động
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

    -- Thực thi SQL động
    EXEC sp_executesql @sql, 
        N'@entityId INT, @dishId INT', 
        @entityId = @entityId, 
        @dishId = @dishId;
END
GO

-- TODO: Xoá món ăn khỏi thực thể
CREATE OR ALTER PROCEDURE sp_DeleteDishFromEntity
    @entityType NVARCHAR(50), -- Loại entity ('category', 'combo', 'region', 'branch')
    @entityId INT,            -- ID của entity
    @dishId INT               -- ID của dish
AS
BEGIN
    -- Validate entity và dish
    EXEC dbo.sp_Validate @type = @entityType, @id1 = @entityId;
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    -- Validate bổ sung cho combo (nếu cần)
    IF @entityType = 'combo'
    BEGIN
        EXEC dbo.sp_Validate @type = 'dish_is_combo', @id1 = @entityId;
        EXEC dbo.sp_Validate @type = 'dish_no_combo', @id1 = @dishId;
    END

    -- Xây dựng tên bảng dựa trên entityType
    DECLARE @tableName NVARCHAR(50) = 
        CASE @entityType
            WHEN 'category' THEN 'CategoryDish'
            WHEN 'combo' THEN 'ComboDish'
            WHEN 'region' THEN 'RegionDish'
            WHEN 'branch' THEN 'BranchDish'
        END;

    -- Xây dựng SQL động
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        DELETE FROM ' + QUOTENAME(@tableName) + N'
        WHERE ' + QUOTENAME(@entityType) + N' = @entityId AND dish = @dishId;
    ';

    -- Thực thi SQL động
    EXEC sp_executesql @sql, 
        N'@entityId INT, @dishId INT', 
        @entityId = @entityId, 
        @dishId = @dishId;
END
GO
