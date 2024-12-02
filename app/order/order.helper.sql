USE SSMORI
GO

-- ! Tính phí ship dựa trên khoảng cách
CREATE OR ALTER FUNCTION fn_CalculateShipCost(
    @distanceKm INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @result DECIMAL(10,2) = 0
    DECLARE @freeDistance INT
    DECLARE @costPerKm DECIMAL(10,2)

    -- Lấy các thông số từ bảng Const
    SELECT @freeDistance = freeDistance, @costPerKm = costPerKm
    FROM Const

    -- Nếu vượt quá khoảng cách miễn phí thì tính phí
    IF @distanceKm > @freeDistance
        SET @result = (@distanceKm - @freeDistance) * @costPerKm

    RETURN @result
END
GO

-- ! Cập nhật giá trị hóa đơn
CREATE OR ALTER PROCEDURE sp_UpdateInvoicePayment
    @invoiceId INT
AS
BEGIN
    DECLARE @total DECIMAL(18, 0)
    DECLARE @dishDiscount DECIMAL(18, 0)
    DECLARE @shipCost DECIMAL(18, 0)
    DECLARE @shipDiscount DECIMAL(18, 0)

    -- Lấy các thông số
    SELECT @total = total, @dishDiscount = dishDiscount, @shipCost = shipCost, @shipDiscount = shipDiscount
    FROM Invoice
    WHERE id = @invoiceId

    -- Cập nhật giá trị hóa đơn
    UPDATE Invoice
    SET totalPayment = (@total - @dishDiscount) + (@shipCost - @shipDiscount)
    WHERE id = @invoiceId
END
GO

-- ! Cập nhật điểm khách hàng và hạng thẻ
CREATE OR ALTER PROCEDURE sp_UpdateCustomerPoint
    @customerId INT,
    @invoiceId INT
AS
BEGIN
    DECLARE @currentPoint INT
    DECLARE @currentType TINYINT
    DECLARE @upgradeAt DATE
    DECLARE @newType TINYINT
    DECLARE @today DATE = GETDATE()

    -- Lấy thông tin khách hàng
    SELECT @currentPoint = point, @currentType = type, @upgradeAt = upgradeAt
    FROM Customer
    WHERE id = @customerId

    -- Lấy điểm từ hóa đơn
    DECLARE @point INT
    SELECT @point = CAST(totalPayment/10000 AS INT)
    FROM Invoice
    WHERE id = @invoiceId

    -- Tính điểm mới
    SET @currentPoint = @currentPoint + @point

    -- Xử lý logic dựa trên hạng thẻ hiện tại
    IF @currentType = 0 -- Membership
    BEGIN
        IF @currentPoint >= 100 -- Điều kiện lên hạng SILVER
        BEGIN
            SET @newType = 1
            UPDATE Customer
            SET type = @newType, point = @currentPoint, upgradeAt = @today
            WHERE id = @customerId
        END
        ELSE
        BEGIN
            -- Cập nhật điểm (giữ nguyên hạng Membership)
            UPDATE Customer
            SET point = @currentPoint
            WHERE id = @customerId
        END
    END
    ELSE IF @currentType = 1 -- Silver
    BEGIN
        -- Kiểm tra tuột hạng
        IF DATEDIFF(YEAR, @upgradeAt, @today) >= 1
        BEGIN
            IF @currentPoint < 50 -- Điều kiện tuột xuống Membership
            BEGIN
                SET @newType = 0
                UPDATE Customer
                SET type = @newType, point = @currentPoint, upgradeAt = NULL
                WHERE id = @customerId
            END
            ELSE IF @currentPoint >= 100 -- Điều kiện nâng hạng lên Gold
            BEGIN
                SET @newType = 2
                UPDATE Customer
                SET type = @newType, point = @currentPoint, upgradeAt = @today
                WHERE id = @customerId
            END
            ELSE
            BEGIN
                -- Giữ hạng Silver, chỉ cập nhật điểm
                UPDATE Customer
                SET point = @currentPoint
                WHERE id = @customerId
            END
        END
        ELSE
        BEGIN
            -- Chưa hết thời gian giữ hạng, cập nhật điểm
            UPDATE Customer
            SET point = @currentPoint
            WHERE id = @customerId
        END
    END
    ELSE IF @currentType = 2 -- Gold
    BEGIN
        -- Kiểm tra tuột hạng
        IF DATEDIFF(YEAR, @upgradeAt, @today) >= 1
        BEGIN
            IF @currentPoint < 100 -- Điều kiện tuột xuống Silver
            BEGIN
                SET @newType = 1
                UPDATE Customer
                SET type = @newType, point = @currentPoint, upgradeAt = @today
                WHERE id = @customerId
            END
            ELSE
            BEGIN
                -- Giữ hạng Gold, cập nhật thời gian và điểm
                UPDATE Customer
                SET point = @currentPoint, upgradeAt = @today
                WHERE id = @customerId
            END
        END
        ELSE
        BEGIN
            -- Chưa hết thời gian giữ hạng, cập nhật điểm
            UPDATE Customer
            SET point = @currentPoint
            WHERE id = @customerId
        END
    END
END
GO

