USE SSMORI
GO

-- TODO: Tạo đánh giá
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

    -- Lấy thông tin invoice
    DECLARE @branchId INT, @employeeId INT
    
    SELECT @branchId = branch, @employeeId = employee FROM Invoice WHERE id = @invoiceId

    -- Tạo đánh giá
    INSERT INTO Review (invoice, service, quality, price, location, comment)
    VALUES (@invoiceId, @service, @quality, @price, @location, @comment)

    -- Cập nhật thống kê đánh giá chi nhánh
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

    -- Cập nhật thống kê đánh giá nhân viên
    MERGE StaticsRateEmployeeDate AS target
    USING (SELECT @employeeId as employee, CAST(GETDATE() AS DATE) as date) AS source
    ON target.employee = source.employee AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            rating1S = rating1S + CASE WHEN @service = 1 THEN 1 ELSE 0 END,
            rating2S = rating2S + CASE WHEN @service = 2 THEN 1 ELSE 0 END,
            rating3S = rating3S + CASE WHEN @service = 3 THEN 1 ELSE 0 END,
            rating4S = rating4S + CASE WHEN @service = 4 THEN 1 ELSE 0 END,
            rating5S = rating5S + CASE WHEN @service = 5 THEN 1 ELSE 0 END
    WHEN NOT MATCHED THEN
        INSERT (employee, date, rating1S, rating2S, rating3S, rating4S, rating5S)
        VALUES (@employeeId, CAST(GETDATE() AS DATE), 
        CASE WHEN @service = 1 THEN 1 ELSE 0 END, 
        CASE WHEN @service = 2 THEN 1 ELSE 0 END, 
        CASE WHEN @service = 3 THEN 1 ELSE 0 END, 
        CASE WHEN @service = 4 THEN 1 ELSE 0 END, 
        CASE WHEN @service = 5 THEN 1 ELSE 0 END);
END
GO  