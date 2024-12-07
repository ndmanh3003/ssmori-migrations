-- TODO: Cập nhật hệ thống
CREATE OR ALTER PROC sp_UpdateSystemConstants  
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