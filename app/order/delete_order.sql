USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_DeleteOrder
    @invoiceId INT,
    @customerId INT = NULL
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'submitted'
    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'invoice_customer', @id1 = @invoiceId, @id2 = @customerId

    -- Delete invoice detail and invoice
    DELETE FROM InvoiceDetail WHERE invoice = @invoiceId
    DELETE FROM InvoiceOnline WHERE invoice = @invoiceId
    DELETE FROM InvoiceReserve WHERE invoice = @invoiceId
    DELETE FROM Invoice WHERE id = @invoiceId
END
GO