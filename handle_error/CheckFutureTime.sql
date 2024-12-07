-- TODO: Kiểm tra thời gian đặt phải là thời gian trong tương lai
CREATE OR ALTER PROCEDURE sp_CheckFutureTime
    @time DATETIME
AS
BEGIN
    IF @time <= GETDATE()
        THROW 50000, 'ERR_INVALID_TIME', 1;
END;
GO