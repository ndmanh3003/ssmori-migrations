USE SSMORI
GO

CREATE OR ALTER PROC sp_SendOtp
    @phone VARCHAR(15),
    @type CHAR(1),
    @otp NVARCHAR(6) OUTPUT
AS
BEGIN
    EXEC dbo.sp_CheckPhone @phone = @phone, @type = @type
    EXEC dbo.sp_CanSendOtp @phone = @phone

    SET @otp = RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS NVARCHAR(6)), 6);
    
    IF EXISTS (SELECT 1 FROM Otp WHERE phone = @phone)
    BEGIN
        UPDATE Otp
        SET otp = HASHBYTES('SHA2_256', @otp), 
            expireAt = DATEADD(MINUTE, 5, GETDATE()), 
            attempt = 0
        WHERE phone = @phone AND type = @type;
    END
    ELSE
    BEGIN
        INSERT INTO Otp (phone, otp, expireAt, type)
        VALUES (@phone, HASHBYTES('SHA2_256', @otp), DATEADD(MINUTE, 5, GETDATE()), @type);
    END
END
GO

CREATE OR ALTER PROC sp_Login
    @phone VARCHAR(15),
    @otp NVARCHAR(6),
    @type CHAR(1)
AS
BEGIN
    EXEC dbo.sp_CanLogin @phone = @phone, @type = @type, @otp = @otp

    -- Delete OTP
    DELETE FROM Otp WHERE phone = @phone AND type = @type;
END
GO