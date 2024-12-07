    USE SSMORI
    GO

    CREATE OR ALTER PROCEDURE sp_CreateCategory
        @nameVN NVARCHAR(100),
        @nameJP NVARCHAR(100)
    AS
    BEGIN
        -- Kiểm tra tính duy nhất của tên tiếng Việt
        EXEC dbo.sp_ValidateUnique @type = 'category_nameVN', @unique = @nameVN;

        -- Kiểm tra tính duy nhất của tên tiếng Nhật
        EXEC dbo.sp_ValidateUnique @type = 'category_nameJP', @unique = @nameJP;

        -- Thêm danh mục mới
        INSERT INTO Category (nameVN, nameJP)
        VALUES (@nameVN, @nameJP);

        -- Lấy ID danh mục vừa tạo
        DECLARE @categoryId INT = SCOPE_IDENTITY();

        -- Trả về ID danh mục vừa tạo
        RETURN @categoryId;
    END
    GO

    CREATE OR ALTER PROCEDURE sp_UpdateCategory
        @categoryId INT,
        @nameVN NVARCHAR(100) = NULL,
        @nameJP NVARCHAR(100) = NULL
    AS
    BEGIN
        -- Kiểm tra danh mục có tồn tại
        EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;

        -- Kiểm tra tính duy nhất của tên tiếng Việt
        EXEC dbo.sp_ValidateUnique @type = 'category_nameVN', @unique = @nameVN

        -- Kiểm tra tính duy nhất của tên tiếng Nhật
        EXEC dbo.sp_ValidateUnique @type = 'category_nameJP', @unique = @nameJP

        -- Cập nhật danh mục
        UPDATE Category
        SET nameVN = COALESCE(@nameVN, nameVN),
            nameJP = COALESCE(@nameJP, nameJP)
        WHERE id = @categoryId

        -- Trả về thông báo thành công
        RETURN 1
    END
    GO

    CREATE OR ALTER PROCEDURE sp_DeleteCategory
        @categoryId INT
    AS
    BEGIN
        -- Kiểm tra danh mục có tồn tại
        EXEC dbo.sp_Validate @type = 'category', @id1 = @categoryId;

        -- Xóa danh mục
        DELETE FROM Category
        WHERE id = @categoryId;

        -- Trả về thông báo thành công
        RETURN 1
    END
    GO
