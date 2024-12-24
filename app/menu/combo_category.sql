USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_ManageCategoryDishes
    @categoryId INT,
    @dishId INT,
    @isDelete BIT
AS
BEGIN
    IF @isDelete = 1
        EXEC dbo.sp_DeleteDishFromEntity @entityType = 'category', @entityId = @categoryId, @dishId = @dishId;
    ELSE
        EXEC dbo.sp_AddDishToEntity @entityType = 'category', @entityId = @categoryId, @dishId = @dishId;
END
GO

CREATE OR ALTER PROCEDURE sp_ManageComboDishes
    @comboId INT,
    @dishId INT,
    @isDelete BIT
AS
BEGIN
    IF @isDelete = 1
        EXEC dbo.sp_DeleteDishFromEntity @entityType = 'combo', @entityId = @comboId, @dishId = @dishId;
    ELSE
        EXEC dbo.sp_AddDishToEntity @entityType = 'combo', @entityId = @comboId, @dishId = @dishId;
END
GO