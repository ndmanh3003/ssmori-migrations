USE SSMORI
GO

-- TODO: Tạo mục món ăn mới
CREATE OR ALTER PROCEDURE sp_CreateCategory
    @name NVARCHAR(100)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'category_name', @unique = @name;

    -- Thêm danh mục mới
    INSERT INTO Category (name)
    VALUES (@name);
END
GO

-- TODO: Câp nhật mục món ăn
CREATE OR ALTER PROCEDURE sp_UpdateCategory
    @categoryId INT,
    @name NVARCHAR(100) = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;
    EXEC dbo.sp_ValidateUnique @type = 'category_name', @unique = @name

    -- Cập nhật danh mục
    UPDATE Category
    SET name = COALESCE(@name, name)
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
