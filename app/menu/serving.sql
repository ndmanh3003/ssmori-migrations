USE SSMORI
GO

-- TODO: Thêm/xóa món ăn trong khu vực
CREATE OR ALTER PROCEDURE sp_ManageRegionDishes
    @regionId INT,
    @dishId INT,
    @isDelete BIT
AS
BEGIN
    IF @isDelete = 1
        EXEC dbo.sp_DeleteDishFromEntity @entityType = 'region', @entityId = @regionId, @dishId = @dishId;
    ELSE
        EXEC dbo.sp_AddDishToEntity @entityType = 'region', @entityId = @regionId, @dishId = @dishId;
END
GO

-- TODO: Thêm/xóa món ăn trong chi nhánh
CREATE OR ALTER PROCEDURE sp_ManageBranchDishes
    @branchId INT,
    @dishId INT,
    @isDelete BIT
AS
BEGIN
    IF @isDelete = 1
        EXEC dbo.sp_DeleteDishFromEntity @entityType = 'branch', @entityId = @branchId, @dishId = @dishId;
    ELSE
        EXEC dbo.sp_AddDishToEntity @entityType = 'branch', @entityId = @branchId, @dishId = @dishId;
END
GO