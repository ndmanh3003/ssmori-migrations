USE SSMORI
GO

-- fn view region and branch
CREATE OR ALTER FUNCTION fn_viewRegionBranch()
RETURNS TABLE
AS
RETURN
(
    SELECT r.id AS regionId, r.name AS regionName, b.*
    FROM Region r
    JOIN Branch b ON r.id = b.region
);
GO

-- fn view menu by branch id
CREATE OR ALTER FUNCTION fn_viewMenuByBranchId(@branchId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT c.*, d.id AS dishId

    FROM Branch b
    JOIN BranchDish bd ON b.id = bd.branch
    JOIN Region r ON b.region = r.id
    JOIN RegionDish rd ON r.id = rd.region
    JOIN Dish d ON rd.dish = d.id AND bd.dish = d.id
    LEFT JOIN CategoryDish cd ON d.id = cd.dish
    LEFT JOIN Category c ON cd.category = c.id

    WHERE b.id = @branchId
);
GO

-- fn view invoice detail
CREATE OR ALTER FUNCTION fn_viewInvoiceDetail(@invoiceId INT, @customerId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT i.*, id.dish, id.quantity, id.sum, ir.guestCount, ir.bookingAt, io.phone, io.address, io.distanceKm, b.name + ' - ' + b.address AS 'branchInfo'

    FROM Invoice i
    LEFT JOIN InvoiceDetail id ON i.id = id.invoice
    LEFT JOIN Branch b ON i.branch = b.id
    LEFT JOIN InvoiceReserve ir ON i.id = ir.invoice
    LEFT JOIN InvoiceOnline io ON i.id = io.invoice

    WHERE i.id = @invoiceId
    AND (i.customer IS NULL OR i.customer = @customerId)
);
GO

-- fn view invoice list
CREATE OR ALTER FUNCTION fn_viewInvoiceList(
    @status NVARCHAR(15), 
    @from DATETIME, 
    @to DATETIME, 
    @in NVARCHAR(15), 
    @customerId INT, 
    @branchId INT, 
    @type CHAR(1),
    @page INT,
    @pageSize INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT i.*, b.name + ' - ' + b.address AS 'branchInfo'

    FROM Invoice i
    LEFT JOIN Branch b ON i.branch = b.id

    WHERE (@status IS NULL OR i.status = @status)
    AND (@from IS NULL OR CAST(i.orderAt AS DATE) >= @from)
    AND (@to IS NULL OR CAST(i.orderAt AS DATE) <= @to)
    AND (@in IS NULL OR CAST(i.orderAt AS DATE) = @in)
    AND (@customerId IS NULL OR i.customer = @customerId)
    AND (@branchId IS NULL OR i.branch = @branchId)
    AND (@type IS NULL OR i.type = @type)

    ORDER BY i.orderAt DESC
    OFFSET (@page - 1) * @pageSize ROWS 
    FETCH NEXT @pageSize ROWS ONLY
);