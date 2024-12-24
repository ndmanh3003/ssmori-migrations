USE SSMORI
GO

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