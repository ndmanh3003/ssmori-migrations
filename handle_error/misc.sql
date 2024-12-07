USE SSMORI
GO

-- TODO: Kiểm tra thời gian đặt phải là thời gian trong tương lai
CREATE OR ALTER PROCEDURE sp_CheckFutureTime
    @time DATETIME
AS
BEGIN
    IF @time <= GETDATE()
        THROW 50000, 'ERR_INVALID_TIME', 1;
END;
GO

-- TODO: Kiểm tra trạng thái của hóa đơn
CREATE OR ALTER PROCEDURE sp_CheckInvoiceStatus
    @id INT,
    @status NVARCHAR(15),
    @other NVARCHAR(15) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id AND status = @status AND (@other IS NULL OR type = @other))
        THROW 50000, 'ERR_INVALID_STATUS', 1;
END;
GO

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
END;
GO

CREATE OR ALTER PROCEDURE sp_CheckDuration
    @duration INT
AS
BEGIN
    IF @duration <= 0
        THROW 50000, 'ERR_INVALID_DURATION', 1;
END;