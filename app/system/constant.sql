CREATE OR ALTER PROCEDURE sp_UpdateSystemConstants
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
	DELETE FROM CONST
    INSERT INTO CONST VALUES(
		@costPerKm,
		@freeDistance,
		@phone,
		@shipMemberDiscount,
		@shipSilverDiscount,
		@shipGoldDiscount,
		@dishMemberDiscount ,
		@dishSilverDiscount ,
		@dishGoldDiscount
	)
END
GO