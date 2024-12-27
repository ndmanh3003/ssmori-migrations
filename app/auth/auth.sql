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
    
    IF EXISTS (SELECT 1 FROM Otp WHERE phone = @phone AND type = @type)
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
    @type CHAR(1),
    @id INT OUTPUT
AS
BEGIN
    EXEC dbo.sp_CanLogin @phone = @phone, @type = @type, @otp = @otp

    -- Delete OTP
    DELETE FROM Otp WHERE phone = @phone AND type = @type;

    -- Return ID
    IF @type = 'C' 
        SELECT @id = id FROM Customer WHERE phone = @phone
    ELSE IF @type = 'B'
        SELECT @id = id FROM Branch WHERE phone = @phone
    ELSE IF @type = 'S' 
        SET @id = 0
END
GO


CREATE OR ALTER PROC sp_Register
    @phone VARCHAR(15),
    @otp NVARCHAR(6),
    @name NVARCHAR(100),
    @phone VARCHAR(15),
    @email VARCHAR(100),
    @gender CHAR(1),
    @id INT OUTPUT
AS
BEGIN
    -- Check login correct
    EXEC dbo.sp_CanLogin @phone = @phone, @type = 'U', @otp = @otp

    -- Create customer
    EXEC dbo.sp_CreateCustomer @name = @name, @phone = @phone, @email = @email, @gender = @gender

    -- Delete OTP
    DELETE FROM Otp WHERE phone = @phone AND type = 'U';

    -- Return Customer ID 
    SELECT @id = id FROM Customer WHERE phone = @phone
END
GO