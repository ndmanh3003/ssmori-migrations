CREATE OR ALTER PROCEDURE sp_AddDish2Region
    @regionId INT,
    @dishId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId
    EXEC dbo.sp_Validate @type = 'region_has_branch', @id1 = @dishId

    -- Lấy danh sách các chi nhánh thuộc khu vực và thêm món ăn nếu chưa tồn tại
    INSERT INTO BranchDish (branch, dish, isServed)
    SELECT b.id, @dishId, 1
    FROM Branch b
    WHERE b.region = @regionId
        AND NOT EXISTS (
        SELECT 1
        FROM BranchDish bd
        WHERE bd.branch = b.id AND bd.dish = @dishId
        );
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDishFromRegion
    @regionId INT,
    @dishId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId

    -- Xóa món ăn khỏi tất cả các chi nhánh trong khu vực
    DELETE FROM BranchDish
    WHERE dish = @dishId
    AND branch IN (SELECT id FROM Branch WHERE region = @regionId)
END
GO

CREATE OR ALTER PROCEDURE sp_ManageBranchDishServing
    @branchId INT,
    @dishId INT,
    @isServed BIT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId
    EXEC dbo.sp_Validate @type = 'branch_dish', @id1 = @branchId, @id2 = @dishId

    -- Cập nhật trạng thái phục vụ món ăn tại chi nhánh
    UPDATE BranchDish
    SET isServed = @isServed
    WHERE branch = @branchId AND dish = @dishId;
END
GO

