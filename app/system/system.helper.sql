USE SSMORI
GO

-- TODO: Thêm món ăn của vùng vào chi nhánh
CREATE OR ALTER PROCEDURE sp_InitDishesInRegionToBranch
    @branchId INT,
    @regionId INT
AS
BEGIN
	DECLARE @branch2 INT
    SELECT TOP 1 @branch2 = id 
    FROM Branch b WHERE b.region = @regionId AND b.isDeleted = 0 AND b.id != @branchId

    IF @branch2 IS NOT NULL
    BEGIN
        INSERT INTO BranchDish (branch, dish, isServed)
        SELECT @branchId, bd.dish, 1
        FROM BranchDish bd
        WHERE bd.branch = @branch2
    END   
END
GO