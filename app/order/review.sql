USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_CreateReview
    @invoiceId INT,
    @service TINYINT,
    @quality TINYINT,
    @price TINYINT,
    @location TINYINT,
    @comment NVARCHAR(255)
AS
BEGIN
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 'paid'
    EXEC dbo.sp_Validate @type = 'no_review', @id1 = @invoiceId

    -- Get branch and employee
    DECLARE @branchId INT, @employeeId INT
    SELECT @branchId = branch, @employeeId = employee FROM Invoice WHERE id = @invoiceId

    -- Create review
    INSERT INTO Review (invoice, service, quality, price, location, comment)
    VALUES (@invoiceId, @service, @quality, @price, @location, @comment)

    -- Update rating
    MERGE StaticsRateBranchDate AS target
    USING (SELECT @branchId as branch, CAST(GETDATE() AS DATE) as date) AS source
    ON target.branch = source.branch AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            avgService = (avgService * totalReview + @service) / (totalReview + 1),
            avgQuality = (avgQuality * totalReview + @quality) / (totalReview + 1),
            avgPrice = (avgPrice * totalReview + @price) / (totalReview + 1),
            avgLocation = (avgLocation * totalReview + @location) / (totalReview + 1),
            totalReview = totalReview + 1
    WHEN NOT MATCHED THEN
        INSERT (branch, date, avgService, avgQuality, avgPrice, avgLocation, totalReview)
        VALUES (@branchId, CAST(GETDATE() AS DATE), @service, @quality, @price, @location, 1);
END
GO  