-- TODO: Chuyển trạng thái hóa đơn sang đang hoàn thành đặt món
CREATE OR ALTER PROCEDURE sp_CompleteOrder
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái ordering, nếu là online thì phải có ít nhất 1 món
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'ordering', @other = 'in_progress'
    EXEC dbo.sp_Validate @type = 'online_has_dish', @id1 = @invoiceId

    -- Chuyển trạng thái sang chờ duyệt
    UPDATE Invoice SET status = 'completed' WHERE id = @invoiceId
END
GO

-- TODO: Chuyển trạng thái hóa đơn sang gửi đơn đặt món
CREATE OR ALTER PROCEDURE sp_SubmitOrder
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái ordering
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'completed'

    -- Chuyển trạng thái sang chờ duyệt
    UPDATE Invoice SET status = 'submited' WHERE id = @invoiceId
END
GO

-- TODO: Chuyển trạng thái hóa đơn sang hủy đơn đặt món
CREATE OR ALTER PROCEDURE sp_CancelOrder
    @invoiceId INT,
    @employeeId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái submited, employee tồn tại
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submited'
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Chuyển trạng thái sang chờ duyệt
    UPDATE Invoice SET status = 'canceled', employee = @employeeId WHERE id = @invoiceId
END
GO

-- TODO: Chuyển trạng thái hóa đơn sang chấp nhận đơn đặt món và chờ được phục vụ
CREATE OR ALTER PROCEDURE sp_WaitingOrder
    @invoiceId INT,
    @employeeId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái submited, employee tồn tại, đơn là đơn reserve
    EXEC dbo.sp_Validate @type = 'invoice_reserve', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submited'
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Chuyển trạng thái sang chờ duyệt
    UPDATE Invoice SET status = 'waiting', employee = @employeeId WHERE id = @invoiceId
END
GO

-- TODO: Chuyển trạng thái hóa đơn sang xuất hóa đơn
CREATE OR ALTER PROCEDURE sp_IssueInvoice
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái completed
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'completed'

    -- Chuyển trạng thái sang chờ thanh toán
    UPDATE Invoice SET status = 'ready' WHERE id = @invoiceId
END