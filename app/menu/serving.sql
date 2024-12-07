USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_AddDish2Region
    @regionId INT,
    @dishId INT
AS
BEGIN
    -- Kiểm tra vùng có tồn tại
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Kiểm tra món ăn có tồn tại
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId

    -- Kiểm tra khu vực có ít nhất 1 chi nhánh
    IF NOT EXISTS (SELECT 1 FROM Branch WHERE region = @regionId)
        THROW 50000, 'ERR_NO_BRANCH_IN_REGION', 1;

    -- Lấy danh sách các chi nhánh thuộc khu vực và thêm món ăn nếu chưa tồn tại
    INSERT INTO BranchDish (branch, dish, isServed)
    SELECT b.id, @dishId, 0 -- Mặc định chưa phục vụ
    FROM Branch b
    WHERE b.region = @regionId
          AND NOT EXISTS (
              SELECT 1
              FROM BranchDish bd
              WHERE bd.branch = b.id AND bd.dish = @dishId
          );

    -- Kiểm tra số dòng được thêm
    DECLARE @rowsInserted INT = 0;
    SET @rowsInserted = @@ROWCOUNT;

    -- Trả về 1 nếu có thêm dòng, ngược lại trả về 0
    RETURN CASE WHEN @rowsInserted > 0 THEN 1 ELSE 0 END;
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteDishFromRegion
    @regionId INT,
    @dishId INT
AS
BEGIN
    -- Kiểm tra vùng có tồn tại
    EXEC dbo.sp_Validate @type = 'region', @id1 = @regionId

    -- Kiểm tra món ăn có tồn tại
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId

    -- Kiểm tra món ăn có tồn tại trong khu vực hay không
    IF NOT EXISTS (
        SELECT 1
        FROM BranchDish bd
        JOIN Branch b ON bd.branch = b.id
        WHERE b.region = @regionId AND bd.dish = @dishId
    )
        RETURN 0

    -- Xóa món ăn khỏi tất cả các chi nhánh trong khu vực
    DELETE FROM BranchDish
    WHERE dish = @dishId
    AND branch IN (SELECT id FROM Branch WHERE region = @regionId)

    -- Thông báo xóa thành công
    RETURN 1
END
GO

CREATE OR ALTER PROCEDURE sp_ManageBranchDishServing
    @branchId INT,
    @dishId INT,
    @isServed BIT
AS
BEGIN
    -- Kiểm tra vùng có tồn tại
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    -- Kiểm tra món ăn có tồn tại
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId

    -- Kiểm tra món ăn có tồn tại tại chi nhánh không
    IF NOT EXISTS (
        SELECT 1
        FROM BranchDish
        WHERE branch = @branchId AND dish = @dishId
    )
        -- Nếu món ăn chưa có tại chi nhánh, ném lỗi
        THROW 50000, 'ERR_DISH_NOT_FOUND_IN_BRANCH', 1;
    
    -- Cập nhật trạng thái phục vụ món ăn tại chi nhánh
    UPDATE BranchDish
    SET isServed = @isServed
    WHERE branch = @branchId AND dish = @dishId;

    RETURN 1
END
GO

