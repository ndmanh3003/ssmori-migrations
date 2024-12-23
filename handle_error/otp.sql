USE SSMORI
GO

-- TODO: Kiểm tra phone tồn tại
CREATE OR ALTER PROCEDURE sp_CheckPhone
    @phone VARCHAR(15),
    @type CHAR(1)
AS
BEGIN
    IF @type = 'C' AND NOT EXISTS (SELECT 1 FROM Customer WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type = 'S' AND NOT EXISTS (SELECT 1 FROM Const WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type = 'B' AND NOT EXISTS (SELECT 1 FROM Branch WHERE phone = @phone)
        THROW 50000, 'ERR_INVALID_PHONE', 1;
    ELSE IF @type NOT IN ('C', 'S', 'B')
        THROW 50000, 'ERR_INVALID_TYPE', 1;
END
GO

-- TODO: Kiểm tra có thể gửi OTP mới
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

-- TODO: Kiểm tra có thể đăng nhập
CREATE OR ALTER PROCEDURE sp_CanLogin
    @phone VARCHAR(15),
    @type CHAR(1),
    @otp NVARCHAR(6)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Otp WHERE phone = @phone AND type = @type)
        THROW 50000, 'ERR_NO_OTP_FOUND', 1;
    
    -- Lấy thông tin mã OTP
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
        -- Tăng số lần thử nếu sai OTP
        UPDATE Otp
        SET attempt = attempt + 1
        WHERE phone = @phone AND type = @type;

        -- Nếu số lần thử đạt giới hạn, thông báo lỗi
        --IF @attempt + 1 >= 3
        --    THROW 50000, 'ERR_OTP_ATTEMPT_LIMIT', 1;

        -- Thông báo lỗi mã OTP sai
        THROW 50000, 'ERR_INVALID_OTP', 1;
    END
END
GO

-- TODO: Kiểm tra có tồn tại mã OTP
CREATE OR ALTER PROCEDURE sp_CheckOtp
    @phone VARCHAR(15),
    @type CHAR(1)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Otp WHERE phone = @phone AND type = @type)
        THROW 50000, 'ERR_NO_OTP_FOUND', 1;
END