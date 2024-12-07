-- TODO: Kiểm tra trạng thái của hóa đơn
CREATE OR ALTER PROCEDURE sp_CheckInvoiceStatus
    @id INT,
    @status NVARCHAR(15),
    @other NVARCHAR(15) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Invoice WHERE id = @id AND status = @status AND (@other IS NULL OR type = @other))
        THROW 50000, 'ERR_INVALID_STATUS', 1;
END;
GO