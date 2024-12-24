USE SSMORI
GO

CREATE OR ALTER PROC sp_CreateSystemConstants  
    @costPerKm DECIMAL(10, 2),
    @freeDistance INT,
    @phone NVARCHAR(15),
	@shipMemberDiscount INT,
	@shipSilverDiscount INT,
	@shipGoldDiscount INT,
	@dishMemberDiscount INT,
	@dishSilverDiscount INT,
	@dishGoldDiscount INT
AS
BEGIN
	DELETE FROM Const
    
    INSERT INTO Const VALUES(
		1,
		@costPerKm,
		@freeDistance,
		@phone,
		@shipMemberDiscount,
		@shipSilverDiscount,
		@shipGoldDiscount,
		@dishMemberDiscount,
		@dishSilverDiscount,
		@dishGoldDiscount
	)
END
GO

CREATE OR ALTER PROC sp_UpdateSystemConstants  
    @costPerKm DECIMAL(10, 2) = NULL,
    @freeDistance INT = NULL,
    @phone NVARCHAR(15) = NULL,
	@shipMemberDiscount INT = NULL,
	@shipSilverDiscount INT = NULL,
	@shipGoldDiscount INT = NULL,
	@dishMemberDiscount INT = NULL,
	@dishSilverDiscount INT = NULL,
	@dishGoldDiscount INT = NULL
AS
BEGIN
	UPDATE Const
    SET costPerKm = COALESCE(@costPerKm, costPerKm),
        freeDistance = COALESCE(@freeDistance, freeDistance),
        phone = COALESCE(@phone, phone),
        shipMemberDiscount = COALESCE(@shipMemberDiscount, shipMemberDiscount),
        shipSilverDiscount = COALESCE(@shipSilverDiscount, shipSilverDiscount),
    	shipGoldDiscount = COALESCE(@shipGoldDiscount, shipGoldDiscount),
        dishMemberDiscount = COALESCE(@dishMemberDiscount, dishMemberDiscount),
        dishSilverDiscount = COALESCE(@dishSilverDiscount, dishSilverDiscount),
        dishGoldDiscount = COALESCE(@dishGoldDiscount, dishGoldDiscount)
	WHERE id = 1
END
GO