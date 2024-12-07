USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_DeleteRelateToDish
    @  INT
AS
BEGIN
    DELETE FROM BranchDish WHERE dish = @dishId
    DELETE FROM CategoryDish WHERE dish = @dishId

    DECLARE @isCombo BIT
    SELECT @isCombo = isCombo 
    FROM Dish 
    WHERE dish = @dishId;

    IF @isCombo = 1
        DELETE FROM ComboDish WHERE combo = @dishId
    ELSE 
        DELETE FROM ComboDish WHERE dish = @dishId
END
GO