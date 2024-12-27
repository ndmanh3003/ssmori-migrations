USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CheckPhone
    @phone VARCHAR(15),
    @type CHAR(1)
AS
BEGIN
    IF @type = 'C' AND NOT EXISTS (SELECT 1 FROM Customer WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type = 'U' AND EXISTS (SELECT 1 FROM Customer WHERE phone = @phone)
        THROW 50000, 'ERR_EXISTS_PHONE', 1;
    ELSE IF @type = 'S' AND NOT EXISTS (SELECT 1 FROM Const WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type = 'B' AND NOT EXISTS (SELECT 1 FROM Branch WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type NOT IN ('C', 'S', 'B', 'U')
        THROW 50000, 'ERR_INVALID_TYPE', 1;
END
GO

CREATE OR ALTER PROCEDURE sp_CanSendOtp
    @phone VARCHAR(15)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Otp WHERE phone = @phone)
    BEGIN
        DECLARE @issueAt DATETIME
        SELECT @issueAt = DATEADD(MINUTE, -5, expireAt) FROM Otp WHERE phone = @phone

        IF DATEDIFF(SECOND, @issueAt, GETDATE()) < 30
            THROW 50000, 'ERR_OTP_TIME', 1;
    END
END
GO

CREATE OR ALTER PROCEDURE sp_CanLogin
    @phone VARCHAR(15),
    @type CHAR(1),
    @otp NVARCHAR(6)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Otp WHERE phone = @phone AND type = @type)
        THROW 50000, 'ERR_NO_OTP_FOUND', 1;
    
    -- Get stored OTP
    DECLARE @storedOtp VARBINARY(32), @expireAt DATETIME, @attempt TINYINT;
    SELECT @storedOtp = otp, @expireAt = expireAt, @attempt = attempt 
    FROM Otp 
    WHERE phone = @phone AND type = @type;
    
    IF GETDATE() > @expireAt
        THROW 50000, 'ERR_OTP_EXPIRED', 1;

    IF @attempt >= 3
        THROW 50000, 'ERR_OTP_ATTEMPT_LIMIT', 1;

    IF HASHBYTES('SHA2_256', @otp) <> @storedOtp
    BEGIN
        -- Increase attempt
        UPDATE Otp
        SET attempt = attempt + 1
        WHERE phone = @phone AND type = @type;

        THROW 50000, 'ERR_INVALID_OTP', 1;
    END
END
GO
