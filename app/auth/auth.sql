USE SSMORI
GO

-- TODO: Gửi mã OTP
CREATE OR ALTER PROC sp_SendOtp
    @phone VARCHAR(15),
    @type CHAR(1),
    @otp NVARCHAR(6) OUTPUT
AS
BEGIN
    EXEC dbo.sp_CheckPhone @phone = @phone, @type = @type
    EXEC dbo.sp_CanSendOtp @phone = @phone

    -- Tạo mã OTP
    SET @otp = RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS NVARCHAR(6)), 6);
    
    IF EXISTS (SELECT 1 FROM Otp WHERE phone = @phone)
    BEGIN
        -- Cập nhật mã OTP
        UPDATE Otp
        SET otp = HASHBYTES('SHA2_256', @otp), 
            expireAt = DATEADD(MINUTE, 5, GETDATE()), 
            attempt = 0
        WHERE phone = @phone AND type = @type;
    END
    ELSE
    BEGIN
        -- Thêm mã OTP mới
        INSERT INTO Otp (phone, otp, expireAt, type)
        VALUES (@phone, HASHBYTES('SHA2_256', @otp), DATEADD(MINUTE, 5, GETDATE()), @type);
    END
END
GO

-- TODO: Đăng nhập với mã OTP
CREATE OR ALTER PROC sp_Login
    @phone VARCHAR(15),
    @otp NVARCHAR(6),
    @type CHAR(1)
AS
BEGIN
    EXEC dbo.sp_CanLogin @phone = @phone, @type = @type, @otp = @otp

    -- Xóa mã OTP sau khi đăng nhập thành công
    DELETE FROM Otp WHERE phone = @phone AND type = @type;
END
GO


-- TODO: Lấy thời gian để gửi mã OTP
-- CREATE OR ALTER PROC sp_GetTimeOtp
--     @phone VARCHAR(15),
--     @type CHAR(1),
--     @time INT OUTPUT
-- AS
-- BEGIN
--     EXEC dbo.sp_CheckOtp @phone = @phone, @type = @type

--     -- Lấy thông tin mã OTP
--     DECLARE @issueAt DATETIME;
--     SELECT @issueAt = DATEADD(MINUTE, -5, expireAt) FROM Otp WHERE phone = @phone AND type = @type;

--     DECLARE @timeCanSend DATETIME 
--     SET @timeCanSend = DATEADD(SECOND, 30, @issueAt)

--     IF @timeCanSend > GETDATE()
--         SET @time = DATEDIFF(SECOND, GETDATE(), @timeCanSend)
--     ELSE
--         SET @time = 0
-- END
