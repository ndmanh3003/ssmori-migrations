-- TODO: Kiểm tra số thứ tự của món ăn trong danh mục/combo
CREATE OR ALTER PROCEDURE sp_ValidateNoInCategory
    @id INT,
    @no TINYINT,
    @isCombo BIT = NULL
AS
BEGIN
    IF @no < 0
        THROW 50000, 'ERR_INVALID_NO', 1

    DECLARE @total INT;

    IF @isCombo = 1
        SELECT @total = COUNT(*) FROM ComboDish WHERE combo = @id;
    ELSE
        SELECT @total = COUNT(*) FROM CategoryDish WHERE category = @id;

    IF @no > @total + 1
        THROW 50000, 'ERR_INVALID_POSITION', 1;
END
