-- TODO: Thêm/xóa/cập nhật vị trí món ăn trong danh mục
CREATE OR ALTER PROCEDURE sp_ManageCategoryDishes
    @categoryId INT,
    @dishId INT,
    @no TINYINT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId
    EXEC dbo.sp_ValidateNoInCategory @id = @categoryId, @no = @no

    -- Lấy tổng số món trong danh mục
    DECLARE @total TINYINT
    SELECT @total = COUNT(*) FROM CategoryDish WHERE category = @categoryId

    -- Lấy vị trí cũ của món
    DECLARE @oldNo TINYINT = NULL
    SELECT @oldNo = no FROM CategoryDish WHERE category = @categoryId AND dish = @dishId

    -- Xóa món ăn khỏi danh mục
    IF @no = 0
    BEGIN
        DELETE FROM CategoryDish
        WHERE category = @categoryId AND dish = @dishId

        -- Điều chỉnh thứ tự các món sau khi xóa
        UPDATE CategoryDish
        SET no = no - 1
        WHERE category = @categoryId AND no > @oldNo
    END
    
    -- Thêm món vào cuối danh mục
    ELSE IF @no = @total + 1
    BEGIN
        -- Nếu món chưa tồn tại, cập nhật vị trí cuối cùng
        IF @oldNo IS NULL
        BEGIN
            INSERT INTO CategoryDish (category, dish, no)
            VALUES (@categoryId, @dishId, @no)
        END
    END

    -- Cập nhật vị trí món ăn trong danh mục
    ELSE
    BEGIN
        -- Nếu món đã tồn tại, cập nhật vị trí
        IF @oldNo IS NOT NULL
        BEGIN
            IF @no < @oldNo
            BEGIN
                -- Dời các món phía sau để chèn món vào vị trí mới
                UPDATE CategoryDish
                SET no = no + 1
                WHERE category = @categoryId AND no >= @no AND no < @oldNo
            END
            ELSE
            BEGIN
                -- Dời các món phía trước để chèn món vào vị trí mới
                UPDATE CategoryDish
                SET no = no - 1
                WHERE category = @categoryId AND no > @oldNo AND no <= @no
            END

            -- Cập nhật vị trí mới cho món
            UPDATE CategoryDish
            SET no = @no
            WHERE category = @categoryId AND dish = @dishId
        END
    END
END
GO

-- TODO: Quản lý món ăn trong combo
CREATE OR ALTER PROCEDURE sp_ManageComboDishes
    @comboId INT,
    @dishId INT,
    @no TINYINT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'dish_is_combo', @id1 = @comboId
    EXEC dbo.sp_Validate @type = 'dish_no_combo', @id1 = @dishId
    EXEC dbo.sp_ValidateNoInCategory @id = @comboId, @no = @no, @isCombo = 1

    -- Lấy tổng số món trong combo
    DECLARE @total TINYINT
    SELECT @total = COUNT(*) FROM ComboDish WHERE combo = @comboId

    -- Lấy vị trí cũ của món
    DECLARE @oldNo TINYINT = NULL
    SELECT @oldNo = no FROM ComboDish WHERE combo = @comboId AND dish = @dishId

    -- Xóa món ăn khỏi combo
    IF @no = 0
    BEGIN
        DELETE FROM ComboDish
        WHERE combo = @comboId AND dish = @dishId

        -- Điều chỉnh thứ tự các món sau khi xóa
        UPDATE ComboDish
        SET no = no - 1
        WHERE combo = @comboId AND no > @oldNo
    END
    
    -- Thêm món vào cuối combo
    ELSE IF @no = @total + 1
    BEGIN
        -- Nếu món chưa tồn tại, cập nhật vị trí cuối cùng
        IF @oldNo IS NULL
        BEGIN
            INSERT INTO ComboDish (combo, dish, no)
            VALUES (@comboId, @dishId, @no)
        END
    END

    -- Cập nhật vị trí món ăn trong combo
    ELSE
    BEGIN
        -- Nếu món đã tồn tại, cập nhật vị trí
        IF @oldNo IS NOT NULL
        BEGIN
            IF @no < @oldNo
            BEGIN
                -- Dời các món phía sau để chèn món vào vị trí mới
                UPDATE ComboDish
                SET no = no + 1
                WHERE combo = @comboId AND no >= @no AND no < @oldNo
            END
            ELSE
            BEGIN
                -- Dời các món phía trước để chèn món vào vị trí mới
                UPDATE ComboDish
                SET no = no - 1
                WHERE combo = @comboId AND no > @oldNo AND no <= @no
            END

            -- Cập nhật vị trí mới cho món
            UPDATE ComboDish
            SET no = @no
            WHERE combo = @comboId AND dish = @dishId
        END
    END
END
GO