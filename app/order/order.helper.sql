USE SSMORI
GO

CREATE OR ALTER FUNCTION fn_CalculateShipCost(
    @distanceKm INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @result DECIMAL(10,2) = 0
    DECLARE @freeDistance INT
    DECLARE @costPerKm DECIMAL(10,2)

    -- Get const
    SELECT @freeDistance = freeDistance, @costPerKm = costPerKm FROM Const

    -- Calculate ship cost
    IF @distanceKm > @freeDistance
        SET @result = (@distanceKm - @freeDistance) * @costPerKm

    RETURN @result
END
GO

CREATE OR ALTER PROCEDURE sp_UpdateCustomerPoint
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId

    DECLARE @currentPoint INT
    DECLARE @currentType CHAR(1)
    DECLARE @upgradeAt DATE

    -- Get customer
    DECLARE @customerId INT
    SELECT @customerId = customer FROM Invoice WHERE id = @invoiceId

    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId 

    -- Get current point and type
    SELECT @currentPoint = point, @currentType = type, @upgradeAt = upgradeAt FROM Customer WHERE id = @customerId

    -- Get point from total payment
    DECLARE @point INT
    SELECT @point = CAST(totalPayment/100000 AS INT) FROM Invoice WHERE id = @invoiceId

    -- Update point
    SET @currentPoint = @currentPoint + @point

    -- Check upgrade/downgrade card
    DECLARE @isUpgrade BIT = 0
    DECLARE @newType CHAR(1) = @currentType

    IF @currentType = 'M'
        IF @currentPoint >= 100 -- Condition to upgrade to Silver
        BEGIN
            SET @newType = 'S'
            SET @isUpgrade = 1
        END

    ELSE IF @currentType = 'S'
    BEGIN
        IF DATEDIFF(YEAR, @upgradeAt, GETDATE()) >= 1
        BEGIN
            IF @currentPoint < 50 -- Condition to downgrade to Member
                SET @newType = 'M'
            ELSE IF @currentPoint >= 100 -- Condition to upgrade to Gold
            BEGIN
                SET @newType = 'G'
                SET @isUpgrade = 1
            END
        END
    END
    
    ELSE IF @currentType = 'G'
    BEGIN
        IF DATEDIFF(YEAR, @upgradeAt, GETDATE()) >= 1
        BEGIN
            IF @currentPoint < 100 -- Condition to downgrade to Silver
                SET @newType = 'S'
        END
    END

    -- Update customer
    UPDATE Customer
    SET point = @currentPoint, type = @newType, upgradeAt = CASE WHEN @isUpgrade = 1 THEN GETDATE() ELSE @upgradeAt END
    WHERE id = @customerId
END
GO

CREATE OR ALTER PROCEDURE sp_ApplyDiscount
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'completed'

    -- Get customer
    DECLARE @customerId INT
    SELECT @customerId = customer FROM Invoice WHERE id = @invoiceId

    EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId 

    -- Get invoice total and ship cost
    DECLARE @total DECIMAL(10,2), @shipCost DECIMAL(10,2), @customerType TINYINT
    SELECT @total = total, @shipCost = shipCost, @customerType = c.type
    FROM Invoice i
    LEFT JOIN Customer c ON i.customer = c.id
    WHERE i.id = @invoiceId

    -- Get discount
    DECLARE @shipDiscount INT, @dishDiscount INT

    SELECT @shipDiscount = CASE 
        WHEN @customerType = 'M' THEN shipMemberDiscount
        WHEN @customerType = 'S' THEN shipSilverDiscount
        WHEN @customerType = 'G' THEN shipGoldDiscount
        ELSE 0
    END
    FROM Const

    SELECT @dishDiscount = CASE 
        WHEN @customerType = 'M' THEN dishMemberDiscount
        WHEN @customerType = 'S' THEN dishSilverDiscount
        WHEN @customerType = 'G' THEN dishGoldDiscount
        ELSE 0
    END
    FROM Const
   
    -- Update invoice
    UPDATE Invoice
    SET 
        dishDiscount = @total * @dishDiscount / 100,
        shipDiscount = @shipCost * @shipDiscount / 100
    WHERE id = @invoiceId
	
	-- Update total
    UPDATE Invoice
    SET totalPayment = total - dishDiscount - shipDiscount
    WHERE id = @invoiceId
END
GO

