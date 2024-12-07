USE SSMORI
GO

-- TODO: Gán order cho bàn
CREATE OR ALTER PROCEDURE sp_AssignOrder2Table
    @invoiceId INT,
    @tbl INT,
    @employeeId INT = NULL
AS
BEGIN
    EXEC dbo.sp_Validate @type = 'employee', @id1 = @employeeId

    -- Lấy branch từ employee
    DECLARE @branchId INT
    SELECT @branchId = branch FROM Employee WHERE id = @employeeId

    EXEC dbo.sp_Validate @type = 'table_empty', @id1 = @branchId, @id2 = @tbl

    -- Nếu không có invoice thì tạo mới
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO Invoice (status, orderAt, employee, branch, type)
        VALUES ('in_progress', GETDATE(), @employeeId, @branchId, 'W')

        SET @invoiceId = SCOPE_IDENTITY()
    END
    ELSE
    BEGIN
        -- Cập nhật trạng thái invoice
        UPDATE Invoice
        SET status = 'in_progress'
        WHERE id = @invoiceId
    END

    -- Gán bàn cho invoice
    UPDATE BranchTable
    SET invoice = @invoiceId
    WHERE branch = @branchId AND tbl = @tbl
END
GO
