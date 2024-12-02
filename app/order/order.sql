USE SSMORI
GO

-- ! Procedure tạo đơn hàng online
CREATE OR ALTER PROCEDURE sp_CreateOnlineOrder
    @phone VARCHAR(15),
    @address NVARCHAR(255),
    @distanceKm INT,
    @branchId INT,
    @customerId INT = NULL,
    @invoiceId INT OUTPUT
AS
BEGIN
    -- Kiểm tra branch tồn tại và hỗ trợ ship, customer tồn tại
    EXEC dbo.sp_Validate @type = 'branch_shipping', @id1 = @branchId

    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    -- Tính phí ship và tạo invoice mới
    DECLARE @shipCost DECIMAL(10,2) = dbo.fn_CalculateShipCost(@distanceKm)

    INSERT INTO Invoice (status, orderAt, customer, branch, isOnline, shipCost)
    VALUES (0, GETDATE(), @customerId, @branchId, 1, @shipCost)

    SET @invoiceId = SCOPE_IDENTITY()

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId

    -- Tạo thông tin giao hàng
    INSERT INTO InvoiceOnline (invoice, phone, address, distanceKm)
    VALUES (@invoiceId, @phone, @address, @distanceKm)
END
GO

-- ! Procedure cập nhật đơn hàng online
CREATE OR ALTER PROCEDURE sp_UpdateOnlineOrder
    @invoiceId INT,
    @phone VARCHAR(15) = NULL,
    @address NVARCHAR(255) = NULL,
    @distanceKm INT = NULL
AS
BEGIN
    -- Kiểm tra invoice tồn tại và là đơn online
    EXEC dbo.sp_Validate @type = 'invoice_online', @id1 = @invoiceId

    -- Cập nhật thông tin giao hàng
    UPDATE InvoiceOnline
    SET phone = COALESCE(@phone, phone),
        address = COALESCE(@address, address),
        distanceKm = COALESCE(@distanceKm, distanceKm)
    WHERE invoice = @invoiceId

    -- Cập nhật phí ship nếu có thay đổi khoảng cách
    IF @distanceKm IS NOT NULL
    BEGIN
        DECLARE @shipCost DECIMAL(10,2) = dbo.fn_CalculateShipCost(@distanceKm)
            
        UPDATE Invoice 
        SET shipCost = @shipCost
        WHERE id = @invoiceId

        EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
    END
END
GO

-- ! Procedure tạo đơn đặt bàn
CREATE OR ALTER PROCEDURE sp_CreateReserveOrder
    @branchId INT,
	@guestCount INT,
    @bookingAt DATETIME,
    @phone VARCHAR(15),
    @customerId INT = NULL,
    @invoiceId INT OUTPUT
AS
BEGIN
    -- Kiểm tra branch và customer tồn tại, thời gian đặt phải trong tương lai
    EXEC dbo.sp_Validate @type = 'branch', @id1 = @branchId

    IF @customerId IS NOT NULL
        EXEC dbo.sp_Validate @type = 'customer', @id1 = @customerId

    EXEC dbo.sp_CheckFutureTime @time = @bookingAt

    -- Tạo invoice mới
    INSERT INTO Invoice (status, orderAt, customer, branch, isOnline)
    VALUES (0, GETDATE(), @customerId, @branchId, 0)

    SET @invoiceId = SCOPE_IDENTITY()

    -- Tạo thông tin đặt bàn
    INSERT INTO InvoiceReserve (invoice, guestCount, bookingAt, phone)
    VALUES (@invoiceId, @guestCount, @bookingAt, @phone)
END
GO

-- ! Procedure cập nhật đơn đặt bàn
CREATE OR ALTER PROCEDURE sp_UpdateReserveOrder
    @invoiceId INT,
    @guestCount INT = NULL,
    @bookingAt DATETIME = NULL,
    @phone VARCHAR(15) = NULL
AS
BEGIN
    -- Kiểm tra invoice tồn tại và là đơn đặt bàn, thời gian đặt phải trong tương lai
    EXEC dbo.sp_Validate @type = 'invoice_reserve', @id1 = @invoiceId

    IF @bookingAt IS NOT NULL
        EXEC dbo.sp_CheckFutureTime @time = @bookingAt

    -- Cập nhật thông tin đặt bàn
    UPDATE InvoiceReserve
    SET guestCount = COALESCE(@guestCount, guestCount),
        bookingAt = COALESCE(@bookingAt, bookingAt),
        phone = COALESCE(@phone, phone)
    WHERE invoice = @invoiceId
END
GO

-- ! Procedure quản lý chi tiết đơn hàng
CREATE OR ALTER PROCEDURE sp_ManageOrderDetail
    @invoiceId INT,
    @dishId INT,
    @quantity INT
AS
BEGIN
    -- Kiểm tra invoice, dish tồn tại
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId

    EXEC dbo.sp_Validate @type = 'dish', @id1 = @dishId

    -- Lấy thông tin đơn hàng
    DECLARE @isOnline BIT, @branchId INT

    SELECT @isOnline = isOnline, @branchId = branch
    FROM Invoice 
    WHERE id = @invoiceId

    -- Kiểm tra đơn online thì dish có thể ship và dish được phục vụ ở branch này
    IF @isOnline = 1
        EXEC dbo.sp_Validate @type = 'dish_shipping', @id1 = @dishId

    EXEC dbo.sp_Validate @type = 'branch_dish_served', @id1 = @branchId, @id2 = @dishId

    -- Xử lý quantity
    IF @quantity = 0
    BEGIN
        -- Xóa món ăn khỏi đơn
        DELETE FROM InvoiceDetail
        WHERE invoice = @invoiceId AND dish = @dishId
    END
    ELSE
    BEGIN
        -- Lấy giá món ăn
        DECLARE @price DECIMAL(10,2)
        SELECT @price = price FROM Dish WHERE id = @dishId

        -- Thêm/cập nhật món ăn
        IF EXISTS (SELECT 1 FROM InvoiceDetail WHERE invoice = @invoiceId AND dish = @dishId)
        BEGIN
            UPDATE InvoiceDetail
            SET quantity = @quantity,
                sum = @quantity * @price
            WHERE invoice = @invoiceId AND dish = @dishId
        END
        ELSE
        BEGIN
            INSERT INTO InvoiceDetail (invoice, dish, quantity, sum)
            VALUES (@invoiceId, @dishId, @quantity, @quantity * @price)
        END
    END

    -- Cập nhật tổng tiền invoice
    UPDATE Invoice
    SET total = (SELECT ISNULL(SUM(sum), 0) FROM InvoiceDetail WHERE invoice = @invoiceId)
    WHERE id = @invoiceId

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
END
GO

-- ! Procedure xử lý áp dụng discount cho đơn hàng
CREATE OR ALTER PROCEDURE sp_ApplyDiscount
    @invoiceId INT,
    @discountId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và discount có hiệu lực
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId

    EXEC dbo.sp_Validate @type = 'discount_active', @id1 = @discountId

    -- Lấy thông tin invoice và khách hàng
    DECLARE @customerType TINYINT, @total DECIMAL(10,2), @shipCost DECIMAL(10,2)
    DECLARE @discountType TINYINT, @minApply DECIMAL(10,2)
    DECLARE @valueDiscount DECIMAL(10,2)

    SELECT @total = total, @shipCost = shipCost, @customerType = c.type
    FROM Invoice i
    LEFT JOIN Customer c ON i.customer = c.id
    WHERE i.id = @invoiceId

    -- Lấy thông tin discount
    SELECT 
        @discountType = type,
        @minApply = minApply,
        @valueDiscount = CASE 
            WHEN @customerType = 0 THEN valueMember
            WHEN @customerType = 1 THEN valueSilver
            WHEN @customerType = 2 THEN valueGold
            ELSE valueAll
        END
    FROM Discount
    WHERE id = @discountId

    -- Kiểm tra điều kiện áp dụng
    EXEC dbo.sp_CheckDiscountCondition @discountType = @discountType, @total = @total, @shipCost = @shipCost, @minApply = @minApply

    -- Áp dụng discount
    UPDATE Invoice
    SET 
        dishDiscount = CASE 
            WHEN @discountType = 0 THEN @total * @valueDiscount / 100
            WHEN @discountType = 1 THEN @valueDiscount
            ELSE dishDiscount
        END,
        shipDiscount = CASE
            WHEN @discountType = 2 THEN @shipCost * @valueDiscount / 100
            WHEN @discountType = 3 THEN @valueDiscount
            ELSE shipDiscount
        END
    WHERE id = @invoiceId

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
END
GO

-- ! Procedure xóa discount khỏi đơn hàng
CREATE OR ALTER PROCEDURE sp_RemoveDiscount
    @invoiceId INT,
    @isDiscount4Dish BIT
AS
BEGIN
    -- Kiểm tra invoice tồn tại
    EXEC dbo.sp_Validate @type = 'invoice', @id1 = @invoiceId

    -- Xóa discount tương ứng
    UPDATE Invoice
    SET dishDiscount = CASE WHEN @isDiscount4Dish = 1 THEN 0 ELSE dishDiscount END,
        shipDiscount = CASE WHEN @isDiscount4Dish = 0 THEN 0 ELSE shipDiscount END
    WHERE id = @invoiceId

    EXEC dbo.sp_UpdateInvoicePayment @invoiceId = @invoiceId
END
GO

-- ! Procedure gửi đơn hàng để duyệt
CREATE OR ALTER PROCEDURE sp_SubmitOrder
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái ordering, nếu là đơn online thì phải có món ăn
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 0

    EXEC dbo.sp_Validate @type = 'online_dish', @id1 = @invoiceId

    -- Chuyển trạng thái sang chờ duyệt
    UPDATE Invoice
    SET status = 1
    WHERE id = @invoiceId
END
GO

-- ! Procedure hủy đơn hàng
CREATE OR ALTER PROCEDURE sp_CancelOrder
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái chờ duyệt
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 1

    -- Hủy đơn
    UPDATE Invoice
    SET status = 6
    WHERE id = @invoiceId
END
GO

-- ! Procedure duyệt đơn hàng
CREATE OR ALTER PROCEDURE sp_AcceptOrder
    @invoiceId INT,
    @employeeId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang ở trạng thái chờ duyệt, employee tồn tại
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 1

    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Duyệt đơn và cập nhật nhân viên xử lý
    UPDATE Invoice
    SET status = 2,
        employee = @employeeId
    WHERE id = @invoiceId
END
GO

-- ! Procedure gán đơn hàng cho bàn
CREATE OR ALTER PROCEDURE sp_AssignOrder2Table
    @invoiceId INT,
    @tbl INT,
    @employeeId INT = NULL
AS
BEGIN
    -- Kiểm tra employee tồn tại
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Lấy branch từ employee
    DECLARE @branchId INT

    SELECT @branchId = branch FROM Employee WHERE id = @employeeId

    -- Kiểm tra bàn có trống không
    EXEC dbo.sp_Validate @type = 'table_empty', @id1 = @branchId, @id2 = @tbl

    -- Nếu không có invoice thì tạo mới
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO Invoice (status, orderAt, employee, branch, isOnline)
        VALUES (3, GETDATE(), @employeeId, @branchId, 0)

        SET @invoiceId = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        -- Cập nhật trạng thái invoice
        UPDATE Invoice
        SET status = 3
        WHERE id = @invoiceId
    END

    -- Gán bàn cho invoice
    UPDATE BranchTable
    SET invoice = @invoiceId
    WHERE branch = @branchId AND tbl = @tbl
END
GO

-- ! Procedure xuất hóa đơn để thanh toán
CREATE OR ALTER PROCEDURE sp_IssueInvoice
    @invoiceId INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang phục vụ
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 3

    -- Lấy thông tin chi nhánh
    DECLARE @branchId INT

    SELECT @branchId = branch FROM Invoice WHERE id = @invoiceId

    -- Cập nhật trạng thái
    UPDATE Invoice SET status = 4 WHERE id = @invoiceId
END
GO

-- ! Procedure xác nhận thanh toán
CREATE OR ALTER PROCEDURE sp_ConfirmPayment
    @invoiceId INT,
    @tbl INT
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đang chờ thanh toán
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 4

    -- Lấy thông tin invoice
    DECLARE @customerId INT, @total DECIMAL(10,2), @branchId INT

    SELECT 
        @customerId = customer,
        @total = totalPayment,
        @branchId = branch
    FROM Invoice 
    WHERE id = @invoiceId

    -- Cập nhật điểm và nâng hạng cho khách hàng nếu có
    EXEC dbo.sp_UpdateCustomerPoint @customerId = @customerId, @invoiceId = @invoiceId

    -- Cập nhật thống kê doanh thu theo ngày
    MERGE StaticsRevenueDate AS target
    USING (SELECT @branchId as branch, CAST(GETDATE() AS DATE) as date) AS source
    ON target.branch = source.branch AND target.date = source.date
    WHEN MATCHED THEN
        UPDATE SET 
            totalInvoice = totalInvoice + 1,
            totalValue = totalValue + @total
    WHEN NOT MATCHED THEN
        INSERT (branch, date, totalInvoice, totalValue)
        VALUES (@branchId, CAST(GETDATE() AS DATE), 1, @total);

    -- Cập nhật thống kê món ăn theo tháng
    MERGE StaticsDishMonth AS target
    USING (
        SELECT 
            @branchId as branch, 
            DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as date,
            dish, 
            SUM(quantity) as totalQuantity
        FROM InvoiceDetail
        WHERE invoice = @invoiceId
        GROUP BY dish
    ) AS source
    ON target.branch = source.branch AND target.date = source.date AND target.dish = source.dish
    WHEN MATCHED THEN
        UPDATE SET 
            totalDish = totalQuantity + source.totalQuantity
    WHEN NOT MATCHED THEN
        INSERT (branch, date, dish, totalDish)
        VALUES (source.branch, source.date, source.dish, source.totalQuantity);

    -- Kiểm tra bàn có đang phục vụ đúng invoice này không
    EXEC dbo.sp_Validate @type = 'table_invoice', @id1 = @branchId, @id2 = @tbl, @id3 = @invoiceId

    -- Cập nhật trạng thái và xóa invoice khỏi bàn
    UPDATE Invoice SET status = 5 WHERE id = @invoiceId
    UPDATE BranchTable SET invoice = NULL WHERE branch = @branchId AND tbl = @tbl
END
GO

-- ! Procedure tạo đánh giá cho đơn hàng
CREATE OR ALTER PROCEDURE sp_CreateReview
    @invoiceId INT,
    @service TINYINT,
    @quality TINYINT,
    @price TINYINT,
    @location TINYINT,
    @comment NVARCHAR(255)
AS
BEGIN
    -- Kiểm tra invoice tồn tại và đã thanh toán, chưa đánh giá
    EXEC dbo.sp_CheckInvoiceStatus @id = @invoiceId, @status = 5

    EXEC dbo.sp_Validate @type = 'no_review', @id1 = @invoiceId

    -- Lấy thông tin invoice
    DECLARE @branchId INT, @employeeId INT
    
    SELECT @branchId = branch, @employeeId = employee
    FROM Invoice
    WHERE id = @invoiceId

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