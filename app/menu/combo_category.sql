USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_ManageCategoryDishes
    @categoryId INT,
    @dishId INT,
    @no INT
AS
BEGIN
    -- Kiểm tra danh mục tồn tại
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;

    -- Kiểm tra món ăn tồn tại
    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId;

    -- Lấy số lượng món hiện tại trong danh mục
    DECLARE @currentCount INT;
    SELECT @currentCount = COUNT(*) FROM CategoryDish WHERE categoryId = @categoryId;

    -- Kiểm tra giá trị @no
    -- KO BIẾT CÓ CẦN KIỂM TRA NÀY KHÔNG ?????
    IF @no < 0 OR @no > @currentCount + 1
        THROW 50000, 'ERR_INVALID_POSITION', 1;

    DECLARE @originalNo INT = NULL;
    SELECT @originalNo = no 
    FROM CategoryDish 
    WHERE categoryId = @categoryId AND dishId = @dishId;

    -- Xử lý logic theo @no
    IF @no = 0
    BEGIN
        -- Xóa món khỏi danh mục nếu tồn tại
        IF @originalNo IS NOT NULL
        BEGIN
            DELETE FROM CategoryDish
            WHERE categoryId = @categoryId AND dishId = @dishId;

            -- Điều chỉnh thứ tự các món sau khi xóa
            UPDATE CategoryDish
            SET no = no - 1
            WHERE categoryId = @categoryId AND no > @originalNo
        END
    END
    ELSE IF @no = @currentCount + 1
    BEGIN
        -- Nếu món đã tồn tại, cập nhật vị trí cuối cùng
        IF @originalNo IS NULL
        BEGIN
            -- Chèn món mới vào cuối danh mục
            INSERT INTO CategoryDish (categoryId, dishId, no)
            VALUES (@categoryId, @dishId, @no);
        END
    END
    ELSE
    BEGIN
        -- Nếu món đã tồn tại, cập nhật vị trí
        IF @originalNo IS NOT NULL
        BEGIN
            IF @no < @originalNo
            BEGIN
                -- Dời các món phía sau để chèn món vào vị trí mới
                UPDATE CategoryDish
                SET no = no + 1
                WHERE categoryId = @categoryId AND no >= @no AND no < @originalNo;
            END
            ELSE IF @no > @originalNo
            BEGIN
                -- Dời các món phía trước để chèn món vào vị trí mới
                UPDATE CategoryDish
                SET no = no - 1
                WHERE categoryId = @categoryId AND no > @originalNo AND no <= @no;
            END

            -- Cập nhật vị trí mới cho món
            UPDATE CategoryDish
            SET no = @no
            WHERE categoryId = @categoryId AND dishId = @dishId;
        END
    END

    RETURN 1
END
GO

CREATE OR ALTER PROCEDURE sp_ManageComboDishes
    @comboId INT,
    @dishId INT,
    @no INT
AS
BEGIN
    -- Kiểm tra combo tồn tại
    EXEC dbo.sp_ValidateDishOrCombo @id = @comboId, @isCombo = 1;

    -- Kiểm tra món ăn tồn tại
    EXEC dbo.sp_ValidateDishOrCombo @id = @dishId, @isCombo = 0;

    -- Lấy số lượng món hiện tại trong combo
    DECLARE @currentCount INT;
    SELECT @currentCount = COUNT(*) FROM ComboDish WHERE comboId = @comboId;

    -- Kiểm tra giá trị @no
    IF @no < 0 OR @no > @currentCount + 1
        THROW 50000, 'ERR_INVALID_POSITION', 1;

    DECLARE @originalNo INT = NULL;
    SELECT @originalNo = no 
    FROM ComboDish 
    WHERE comboId = @comboId AND dishId = @dishId;

    -- Xử lý logic theo @no
    IF @no = 0
    BEGIN
        -- Xóa món khỏi combo nếu tồn tại
        IF @originalNo IS NOT NULL
        BEGIN
            DELETE FROM ComboDish
            WHERE comboId = @comboId AND dishId = @dishId;

            -- Điều chỉnh thứ tự các món sau khi xóa
            UPDATE ComboDish
            SET no = no - 1
            WHERE comboId = @comboId AND no > @originalNo;
        END
    END
    ELSE IF @no = @currentCount + 1
    BEGIN
        -- Nếu món chưa tồn tại, thêm vào cuối combo
        IF @originalNo IS NULL
        BEGIN
            INSERT INTO ComboDish (comboId, dishId, no)
            VALUES (@comboId, @dishId, @no);
        END
    END
    ELSE
    BEGIN
        -- Nếu món đã tồn tại, cập nhật vị trí
        IF @originalNo IS NOT NULL
        BEGIN
            IF @no < @originalNo
            BEGIN
                -- Dời các món phía sau để chèn món vào vị trí mới
                UPDATE ComboDish
                SET no = no + 1
                WHERE comboId = @comboId AND no >= @no AND no < @originalNo;
            END
            ELSE IF @no > @originalNo
            BEGIN
                -- Dời các món phía trước để chèn món vào vị trí mới
                UPDATE ComboDish
                SET no = no - 1
                WHERE comboId = @comboId AND no > @originalNo AND no <= @no;
            END

            -- Cập nhật vị trí mới cho món
            UPDATE ComboDish
            SET no = @no
            WHERE comboId = @comboId AND dishId = @dishId;
        END
    END

    RETURN 1;
END
GO

