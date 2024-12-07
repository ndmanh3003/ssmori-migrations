-- TODO: Tính phí ship dựa trên khoảng cách
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
    SELECT @freeDistance = freeDistance, @costPerKm = costPerKm FROM Const

    -- Nếu vượt quá khoảng cách miễn phí thì tính phí
    IF @distanceKm > @freeDistance
        SET @result = (@distanceKm - @freeDistance) * @costPerKm

    RETURN @result
END
GO

-- TODO: Cập nhật giá trị hóa đơn
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

-- TODO: Cập nhật điểm khách hàng và hạng thẻ
CREATE OR ALTER PROCEDURE sp_UpdateCustomerPoint
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId

    DECLARE @currentPoint INT
    DECLARE @currentType CHAR(1)
    DECLARE @upgradeAt DATE

    -- Lấy thông tin khách hàng
    DECLARE @customerId INT
    SELECT @customerId = customer FROM Invoice WHERE id = @invoiceId

    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId 

    -- Lấy thông tin điểm và hạng thẻ hiện tại
    SELECT @currentPoint = point, @currentType = type, @upgradeAt = upgradeAt FROM Customer WHERE id = @customerId

    -- Lấy điểm từ hóa đơn
    DECLARE @point INT
    SELECT @point = CAST(totalPayment/100000 AS INT) FROM Invoice WHERE id = @invoiceId

    -- Tính điểm mới
    SET @currentPoint = @currentPoint + @point

    -- Xử lý logic dựa trên hạng thẻ hiện tại
    DECLARE @isUpgrade BIT = 0
    DECLARE @newType CHAR(1) = @currentType

    IF @currentType = 'M'
        IF @currentPoint >= 100 -- Điều kiện lên hạng SILVER
        BEGIN
            SET @newType = 'S'
            SET @isUpgrade = 1
        END

    ELSE IF @currentType = 'S'
    BEGIN
        IF DATEDIFF(YEAR, @upgradeAt, @today) >= 1
        BEGIN
            IF @currentPoint < 50 -- Điều kiện tuột xuống Membership
                SET @newType = 'M'
            ELSE IF @currentPoint >= 100 -- Điều kiện nâng hạng lên Gold
            BEGIN
                SET @newType = 'G'
                SET @isUpgrade = 1
            END
        END
    END
    
    ELSE IF @currentType = 'G'
    BEGIN
        IF DATEDIFF(YEAR, @upgradeAt, @today) >= 1
        BEGIN
            IF @currentPoint < 100 -- Điều kiện tuột xuống Silver
                SET @newType = 'S'
        END
    END

    -- Cập nhật điểm và hạng thẻ mới
    UPDATE Customer
    SET point = @currentPoint, type = @newType, upgradeAt = CASE WHEN @isUpgrade = 1 THEN @today ELSE @upgradeAt END
    WHERE id = @customerId
END
GO

-- TODO: Áp dụng discount cho hóa đơn
CREATE OR ALTER PROCEDURE sp_ApplyDiscount
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'completed'

    -- Lấy thông tin khách hàng
    DECLARE @customerId INT
    SELECT @customerId = customer FROM Invoice WHERE id = @invoiceId

    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId 

    -- Lấy thông tin invoice
    DECLARE @total DECIMAL(10,2), @shipCost DECIMAL(10,2), @customerType TINYINT
    SELECT @total = total, @shipCost = shipCost, @customerType = c.type
    FROM Invoice i
    LEFT JOIN Customer c ON i.customer = c.id
    WHERE i.id = @invoiceId

    -- Lấy thông tin discount
    DECLARE @shipDiscount INT, @dishDiscount INT

    SELECT @shipDiscount = CASE 
        WHEN @customerType = 'M' THEN shipMemberDiscount
        WHEN @customerType = 'S' THEN shipSilverDiscount
        WHEN @customerType = 'G' THEN shipGoldDiscount
        ELSE 0
    END

    SELECT @dishDiscount = CASE 
        WHEN @customerType = 'M' THEN dishMemberDiscount
        WHEN @customerType = 'S' THEN dishSilverDiscount
        WHEN @customerType = 'G' THEN dishGoldDiscount
        ELSE 0
    END
   
    -- Áp dụng discount cho món ăn và vận chuyển
    UPDATE Invoice
    SET 
        dishDiscount = @total * @dishDiscount / 100,
        shipDiscount = @shipCost * @shipDiscount / 100
    WHERE id = @invoiceId
	
	-- Cập nhật lại thông tin thanh toán cho invoice
    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
END
GO

