USE SSMORI
GO

-- TODO: Tạo mục món ăn mới
CREATE OR ALTER PROCEDURE sp_CreateCategory
    @nameVN NVARCHAR(100),
    @nameJP NVARCHAR(100)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'category_nameVN', @unique = @nameVN;
    EXEC dbo.sp_ValidateUnique @type = 'category_nameJP', @unique = @nameJP;

    -- Thêm danh mục mới
    INSERT INTO Category (nameVN, nameJP)
    VALUES (@nameVN, @nameJP);
END
GO

-- TODO: Câp nhật mục món ăn
CREATE OR ALTER PROCEDURE sp_UpdateCategory
    @categoryId INT,
    @nameVN NVARCHAR(100) = NULL,
    @nameJP NVARCHAR(100) = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;
    EXEC dbo.sp_ValidateUnique @type = 'category_nameVN', @unique = @nameVN
    EXEC dbo.sp_ValidateUnique @type = 'category_nameJP', @unique = @nameJP

    -- Cập nhật danh mục
    UPDATE Category
    SET nameVN = COALESCE(@nameVN, nameVN),
        nameJP = COALESCE(@nameJP, nameJP)
    WHERE id = @categoryId
END
GO

-- TODO: Xóa mục món ăn
CREATE OR ALTER PROCEDURE sp_DeleteCategory
    @categoryId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;

    -- Xóa danh mục
    DELETE FROM Category
    WHERE id = @categoryId;
END
GO
