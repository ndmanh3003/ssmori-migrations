USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateCategory
    @name NVARCHAR(100)
AS
BEGIN
    EXEC dbo.sp_ValidateUnique @type = 'category_name', @unique = @name;

    -- Add new category
    INSERT INTO Category (name)
    VALUES (@name);
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateCategory
    @categoryId INT,
    @name NVARCHAR(100) = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;
    EXEC dbo.sp_ValidateUnique @type = 'category_name', @unique = @name

    -- Update category
    UPDATE Category
    SET name = COALESCE(@name, name)
    WHERE id = @categoryId
END
GO

CREATE OR ALTER PROCEDURE sp_DeleteCategory
    @categoryId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;

    -- Delete category
    DELETE FROM Category
    WHERE id = @categoryId;
END
GO
