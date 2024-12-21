USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_SubmitOrder
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'draft'
    EXEC dbo.sp_Validate @type = 'online_has_dish', @id1 = @invoiceId

    -- Update invoice status
    EXEC dbo.sp_ApplyDiscount @invoiceId = @invoiceId
    UPDATE Invoice SET status = 'submitted' WHERE id = @invoiceId
END
GO

CREATE OR ALTER PROCEDURE sp_CancelOrder
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'

    -- Update invoice status
    UPDATE Invoice SET status = 'canceled', employee = @employeeId WHERE id = @invoiceId
END
GO

CREATE OR ALTER PROCEDURE sp_IssueInvoice
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'

    -- Update invoice status
    UPDATE Invoice SET status = 'issued' WHERE id = @invoiceId
END