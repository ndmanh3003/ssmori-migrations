
CREATE OR ALTER PROCEDURE sp_DeleteOrder
    @invoiceId INT
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'draft'

    -- Delete invoice detail and invoice
    DELETE FROM InvoiceDetail WHERE invoice = @invoiceId
    DELETE FROM Invoice WHERE id = @invoiceId
END
GO