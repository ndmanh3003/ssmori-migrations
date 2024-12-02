--select
select * from Region
select * from Branch
select * from Department
select * from Employee
select * from WorkHistory
select * from Customer
select * from Card
select * from Dish
select * from Category
select * from CategoryDish
select * from ComboDish
select * from BranchDish
select * from Invoice
select * from BranchTable
select * from InvoiceDetail
select * from Discount
select * from Review
select * from Const
select * from Stream
select * from InvoiceReserve
select * from InvoiceOnline
select * from StaticsRevenueDate
select * from StaticsRevenueMonth
select * from StaticsDishMonth
select * from StaticsRateEmployeeDate
select * from StaticsRateBranchDate
select * from OTP

--test file misc
--fn_CalculateShipCost: OK
--insert cho bảng Const
insert Const values (100, 3, '0')

select dbo.fn_CalculateShipCost(2) AS ShipCost --0, ok
select dbo.fn_CalculateShipCost(4) AS ShipCost --100, ok
select dbo.fn_CalculateShipCost(5) AS ShipCost --200, ok

delete from const 
insert Const values (99999999, 3, '0')
SELECT dbo.fn_CalculateShipCost(5) AS ShipCost --Arithmetic overflow error converting numeric to data type numeric.

delete from const 
insert Const values (20000, 3, '0')
select dbo.fn_CalculateShipCost(5) AS ShipCost --40000, ok

--======================================================================================
--sp_UpdateInvoicePayment: OK
--insert cho bảng Invoice -> tham chiếu const, customer, branch, region, employee,...

insert region (name) values
('North'),
('South'),
('Central'),
('West')

INSERT INTO Branch (name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip, region, tableQuantity, floorQuantity)
VALUES
('Branch A', '123 North Street', '08:00', '22:00', '0123456789', 1, 1, 1, 1, 20, 2),
('Branch B', '456 South Avenue', '09:00', '21:00', '0987654321', 1, 0, 1, 2, 15, 1),
('Branch C', '789 Central Road', '07:00', '23:00', '0111222333', 0, 1, 0, 3, 25, 3); 

SET IDENTITY_INSERT Customer ON --vì cái identity
INSERT INTO Customer (id, name, cid, phone, email, gender, type, point, upgradeAt)
VALUES
(1, 'John Doe', 'C001', '0901234567', 'johndoe@example.com', 0, 0, 100, '2024-01-15'),
(2, 'Jane Smith', 'C002', '0902345678', 'janesmith@example.com', 1, 1, 250, '2024-02-20'),
(3, 'Alex Taylor', 'C003', '0903456789', 'alextaylor@example.com', 2, 2, 500, '2024-03-10'),
(4, 'Emily Davis', 'C004', '0904567890', 'emilydavis@example.com', 1, 0, 50, NULL);
SET IDENTITY_INSERT Customer off

INSERT INTO Department (name, salary) VALUES 
('master chef', 5000.00),
('side chef', 3500.00),
('staff', 2800.00),
('manager', 6000.00)

INSERT INTO Employee (name, dob, gender, startAt, branch, department) VALUES
('john doe', '1990-05-10', 0, '2020-01-15', 1, 1),
('jane smith', '1985-08-20', 1, '2019-03-12', 2, 2),
('alex jones', '1992-11-05', 0, '2021-07-01', 1, 3),
('mary brown', '1988-04-22', 1, '2018-02-10', 3, 4)

INSERT INTO WorkHistory (employee, startAt, endAt, branch) VALUES
(1, '2020-01-15', '2022-01-15', 1),
(2, '2019-03-12', '2021-03-12', 2),
(3, '2021-07-01', NULL, 1),
(4, '2018-02-10', '2020-02-10', 3)


SET IDENTITY_INSERT invoice ON
insert into invoice (id, status, orderat, total, shipcost, dishdiscount, shipdiscount, totalpayment, customer, employee, branch, isonline)
values
(1, 1, '2024-01-10 14:30:00', 200.00, 20.00, 10.00, 5.00, 10.00, 1, 1, 1, 1), --totalpayment: 205
(2, 2, '2024-01-12 16:00:00', 350.00, 25.00, 20.00, 10.00, 10.00, 2, 2, 2, 0), --totalpayment: 345
(3, 3, '2024-01-15 18:45:00', 120.00, 15.00, 0.00, 0.00, 10.00, 3, 3, 3, 1) --totalpayment: 135
SET IDENTITY_INSERT invoice off

delete from invoice
select * from invoice

--update cho invoice vừa thêm
exec sp_UpdateInvoicePayment @invoiceId = 1
exec sp_UpdateInvoicePayment @invoiceId = 2
exec sp_UpdateInvoicePayment @invoiceId = 3
select * from invoice --totalpayment được upd

--======================================================================================
--sp_UpdateCustomerPoint: ??, có time thì sửa lại logic nâng giữ hạng, reset thẻ ntn nếu > 1 năm 
select * from customer

update customer 
set point = 100

update customer 
set type = 0
where id = 1

update invoice 
set totalpayment = 50000
where id = 1 

update invoice 
set totalpayment = 250000
where id = 2 

update invoice 
set totalpayment = 50000
where id = 3

exec sp_UpdateCustomerPoint @customerId = 1, @invoiceId = 1 --up to type 1
exec sp_UpdateCustomerPoint @customerId = 2, @invoiceId = 2 --remain
exec sp_UpdateCustomerPoint @customerId = 3, @invoiceId = 3 --remain
insert into invoice (id, status, orderat, total, shipcost, dishdiscount, shipdiscount, totalpayment, customer, employee, branch, isonline)
values
(6, 2, '2024-01-10 14:30:00', 3000000.00, 20.00, 10.00, 5.00, 10.00, 2, 1, 1, 1)
exec sp_UpdateCustomerPoint @customerId = 2, @invoiceId = 6 --remain?? 665 mà vẫn ở type 1
exec sp_UpdateCustomerPoint @customerId = 2, @invoiceId = 6
select * from customer

--===================================================================================================================================================
--file errors
--sp_Validate: OK, không cần giờ vẫn check được
select * from branch
exec sp_Validate @type = 'branch', @id1 = 1 --OK
exec sp_Validate @type = 'branch', @id1 = 4 --ERR_NO_BRANCH

select * from customer
exec sp_Validate @type = 'customer', @id1 = 1 --OK
exec sp_Validate @type = 'customer', @id1 = 6 --ERR_NO_CUSTOMER

exec sp_Validate @type = 'invoice', @id1 = 6 --OK
exec sp_Validate @type = 'invoice', @id1 = 8 --ERR_NO_INVOICE

exec sp_Validate @type = 'discount', @id1 = 1 --ERR_NO_DISCOUNT
 
exec sp_Validate @type = 'branch_dish', @id1 = 1, @id2 = 1 --ERR_NO_BRANCH_DISH

--======================================================================================
--sp_CheckFutureTime: OK
exec sp_CheckFutureTime @time = '2023-12-01 10:00:00' --ERR_INVALID_TIME
exec sp_CheckFutureTime @time = '2023-12-01' --ERR_INVALID_TIME

exec sp_CheckFutureTime @time = '2025-01-01 10:00:00' --OK
exec sp_CheckFutureTime @time = '2025-01-01' --OK

--======================================================================================
--sp_CheckDiscountCondition: OK
--loại là 0, 1:
exec sp_CheckDiscountCondition @discountType = 0, @total = 500, @shipCost = 100, @minApply = 1000 --ERR_NOT_REACH_MINIMUM
exec sp_CheckDiscountCondition @discountType = 0, @total = 5000, @shipCost = 100, @minApply = 1000 --OK

exec sp_CheckDiscountCondition @discountType = 1, @total = 500, @shipCost = 100, @minApply = 1000 --ERR_NOT_REACH_MINIMUM
exec sp_CheckDiscountCondition @discountType = 2, @total = 5000, @shipCost = 100, @minApply = 1000 --OK

--loại là 2, 3:
exec sp_CheckDiscountCondition @discountType = 2, @total = 2000, @shipCost = 300, @minApply = 1000 --ERR_NOT_REACH_MINIMUM
exec sp_CheckDiscountCondition @discountType = 2, @total = 2000, @shipCost = 3000, @minApply = 1000 --OK

exec sp_CheckDiscountCondition @discountType = 3, @total = 2000, @shipCost = 300, @minApply = 1000 --ERR_NOT_REACH_MINIMUM
exec sp_CheckDiscountCondition @discountType = 3, @total = 2000, @shipCost = 1000, @minApply = 1000 --OK


--===================================================================================================================================================
--file orders
--sp_CreateOnlineOrder: fixed
declare @invoiceId int
exec sp_CreateOnlineOrder 
    @phone = '012345678',
    @address = 'test',
    @distanceKm = 10,
    @branchId = 1,
    @customerId = 1,
    @invoiceId = @invoiceId output

select * from Invoice where id = @invoiceId
select * from InvoiceOnline where invoice = @invoiceId

declare @invoiceId int
exec sp_CreateOnlineOrder 
    @phone = '012345678',
    @address = 'test2',
    @distanceKm = 2,
    @branchId = 2,
    @customerId = 2,
    @invoiceId = @invoiceId output

select * from Invoice where id = @invoiceId
select * from InvoiceOnline where invoice = @invoiceId

declare @invoiceId int
exec sp_CreateOnlineOrder 
    @phone = '012345678',
    @address = 'test2',
    @distanceKm = 5,
    @branchId = 3,
    @customerId = 40,
    @invoiceId = @invoiceId output

select * from Invoice where id = @invoiceId --ERR_CANT_SHIP

declare @invoiceId int
exec sp_CreateOnlineOrder 
    @phone = '012345678',
    @address = 'test4',
    @distanceKm = 5,
    @branchId = 2,
    @customerId = 30,
    @invoiceId = @invoiceId output

select * from Invoice where id = @invoiceId --ERR_NO_CUSTOMER

--Lỗi: nếu id identity_insert đang bật thì sẽ dính lỗi: 
--Explicit value must be specified for identity column in table 'Invoice' 
--either when IDENTITY_INSERT is set to ON or when a replication user is inserting into a NOT FOR REPLICATION identity column.
--Fix: Thêm vào SET IDENTITY_INSERT Invoice off và sửa thành onl ở cuối để khi insert tự nhiên sẽ không bị lỗi
declare @invoiceId int
exec sp_CreateOnlineOrder 
    @phone = '012345678',
    @address = 'test5',
    @distanceKm = 6,
    @branchId = 1,
    @customerId = 1,
    @invoiceId = @invoiceId output

select * from Invoice where id = @invoiceId

insert into invoice (id, status, orderat, total, shipcost, dishdiscount, shipdiscount, totalpayment, customer, employee, branch, isonline)
values
(24, 1, '2024-01-10 14:30:00', 200.00, 20.00, 10.00, 5.00, 10.00, 1, 1, 1, 1) --totalpayment: 205

select * from invoice

--======================================================================================
--sp_UpdateOnlineOrder: OK nhưng msg báo đơn không tồn tại bị sai nội dung, nma vẫn acp dc

exec sp_UpdateOnlineOrder 
    @invoiceId = 2, 
    @phone = '0987654321',
    @address = '456 Another Street, Hanoi',
    @distanceKm = 15

--ERR_NOT_ONLINE

exec sp_UpdateOnlineOrder 
    @invoiceId = 14, 
    @phone = '0987654321',
    @address = '456 Another Street, Hanoi',
    @distanceKm = 3

select * from Invoice where id = 14
select * from InvoiceOnline where invoice = 14
--OK

exec sp_UpdateOnlineOrder 
    @invoiceId = 15, 
    @phone = '0987654321',
    @address = '456 Another Street, Hanoi',
    @distanceKm = 6

select * from Invoice where id = 15
select * from InvoiceOnline where invoice = 15
--ship cost-> 60000, OK

exec sp_UpdateOnlineOrder 
    @invoiceId = 1000, 
    @phone = '0987654321',
    @address = '456 Another Street, Hanoi',
    @distanceKm = 6
--ERR_NOT_ONLINE, trả ra hơi msg vì ko tồn tại đơn này

--======================================================================================
--sp_CreateReserveOrder: fixed, lỗi như bên online

DECLARE @invoiceId INT

EXEC sp_CreateReserveOrder
    @branchId = 2, 
    @guestCount = 4,
    @bookingAt = '2024-01-10 18:00:00',
    @phone = '0909876543',
    @customerId = 1,
    @invoiceId = @invoiceId OUTPUT;

-- Kiểm tra kết quả
SELECT * FROM Invoice WHERE id = @invoiceId
SELECT * FROM InvoiceReserve WHERE invoice = @invoiceId
--ERR_INVALID_TIME

DECLARE @invoiceId INT

EXEC sp_CreateReserveOrder
    @branchId = 2, 
    @guestCount = 4,
    @bookingAt = '2025-01-10 18:00:00',
    @phone = '0909876543',
    @customerId = 100,
    @invoiceId = @invoiceId OUTPUT;

-- Kiểm tra kết quả
SELECT * FROM Invoice WHERE id = @invoiceId
SELECT * FROM InvoiceReserve WHERE invoice = @invoiceId
--ERR_NO_CUSTOMER

DECLARE @invoiceId INT

EXEC sp_CreateReserveOrder
    @branchId = 5, 
    @guestCount = 4,
    @bookingAt = '2025-01-10 18:00:00',
    @phone = '0909876543',
    @customerId = 100,
    @invoiceId = @invoiceId OUTPUT;

-- Kiểm tra kết quả
SELECT * FROM Invoice WHERE id = @invoiceId
SELECT * FROM InvoiceReserve WHERE invoice = @invoiceId
--ERR_NO_BRANCH

DECLARE @invoiceId INT

EXEC sp_CreateReserveOrder
    @branchId = 2, 
    @guestCount = 4,
    @bookingAt = '2025-01-10 18:00:00',
    @phone = '0909876543',
    @customerId = 1,
    @invoiceId = @invoiceId OUTPUT;

SELECT * FROM Invoice WHERE id = @invoiceId
SELECT * FROM InvoiceReserve WHERE invoice = @invoiceId
--OK

--======================================================================================
--sp_UpdateReserveOrder: OK

exec sp_UpdateReserveOrder
    @invoiceId = 25, 
    @guestCount = 5,
    @bookingAt = '2024-01-10 19:00:00',
    @phone = '0912345678'

select * from InvoiceReserve where invoice = 25
--ERR_INVALID_TIME

exec sp_UpdateReserveOrder
    @invoiceId = 2, 
    @guestCount = 5,
    @bookingAt = '2025-01-10 19:00:00',
    @phone = '0912345678'

select * from InvoiceReserve where invoice = 2
--ERR_NO_RESERVE

exec sp_UpdateReserveOrder
    @invoiceId = 25, 
    @guestCount = 5,
    @bookingAt = '2025-01-10 19:00:00',
    @phone = '0912345678'

select * from InvoiceReserve where invoice = 25
--OK

--======================================================================================
--sp_ManageOrderDetail: Cần check song song total và dishDiscount vì nếu bị xóa full món => total = 0, có khi bị < dishDiscount => ko cập nhật total
select * from BranchDish
-- Tạo chi nhánh
INSERT INTO Branch (id, name, canShip) VALUES (1, 'Branch D', 1), (2, 'Branch E', 0);

-- Tạo món ăn
INSERT INTO Dish (nameVN, nameJP, price, canShip) VALUES 
('Dish A', 'Dish A_JP', 10000, 1), 
('Dish B', 'Dish B_JP', 20000, 0);

INSERT INTO Discount (type, valueAll, valueMember, valueSilver, valueGold, minApply, startAt, endAt, name, img) VALUES 
(0, 10, 15, 20, 25, 500, GETDATE() - 1, NULL, 'test km', 'ttt')

--them
EXEC sp_ManageOrderDetail 
    @invoiceId = 1, 
    @dishId = 2, 
    @quantity = 2;

select * from invoice where id = 1
--ERR_DISH_NOT_SERVED

insert into branchdish values (1, 2, 1)
exec sp_ManageOrderDetail 
    @invoiceId = 1, 
    @dishId = 2, 
    @quantity = 2

select * from InvoiceDetail where invoice = 1
--OK

--sua so luong
exec sp_ManageOrderDetail 
    @invoiceId = 1, 
    @dishId = 2, 
    @quantity = 3
select * from InvoiceDetail where invoice = 1
--OK

--cap nhat = 0 <=> xoa
EXEC sp_ManageOrderDetail 
    @invoiceId = 1, 
    @dishId = 2, 
    @quantity = 0
select * from InvoiceDetail where invoice = 1
select * from invoice
--Loi: The UPDATE statement conflicted with the CHECK constraint "CK_Invoice_Discount". The conflict occurred in database "SSMORI", table "dbo.Invoice" 
--nhưng vẫn xóa được
--vi phạm CONSTRAINT CK_Invoice_Discount CHECK (shipCost >= shipDiscount AND total >= dishDiscount)
--Check lỗi: vì chỉ có 1 món trong hóa đơn nên khi xóa, total = 0 => cập nhật total = 0 vào thì bị < dishDiscount nên nó ko cập nhật total và báo lỗi constraint

--======================================================================================
--sp_ApplyDiscount: OK
select * from discount
exec sp_ApplyDiscount  
    @invoiceId = 1, 
    @discountId = 1
--ERR_DISCOUNT_NOT_ACTIVE

exec sp_ApplyDiscount  
    @invoiceId = 100, 
    @discountId = 3
--ERR_NO_INVOICE

exec sp_ApplyDiscount  
    @invoiceId = 1, 
    @discountId = 3

update invoice 
set dishDiscount = 0
where id = 1

select * from customer where id = 1
--OK, dishDiscount = 6000

--======================================================================================
--sp_RemoveDiscount: lỗi ở dòng 474, 475, 476
EXEC sp_RemoveDiscount 
    @invoiceId = 1, 
    @isDiscount4Dish = 3

select * from invoice
INSERT INTO Discount (type, valueAll, valueMember, valueSilver, valueGold, minApply, startAt, endAt, name, img) VALUES 
(1, 10, 15, 20, 25, 500, GETDATE() - 1, NULL, 'test km kc', 'ttt')

EXEC sp_RemoveDiscount 
    @invoiceId = 2, 
    @isDiscount4Dish = 3

--Lỗi: chưa apply khuyến mãi vẫn upd được nhưng ko biết update cái gì? 
--Lỗi: không phải đơn online mà vẫn update được
--Lỗi: update nhưng shipdiscount thì vẫn giữ như cũ, ko bị xóa

exec sp_ApplyDiscount  
    @invoiceId = 15, 
    @discountId = 3
--ERR_NOT_REACH_MINIMUM

update Discount 
set minApply = 0
where id = 3

update Discount 
set type = 3
where id = 3

exec sp_ApplyDiscount  
    @invoiceId = 15, 
    @discountId = 3 
select * from invoice where id = 15

exec sp_RemoveDiscount 
    @invoiceId = 15, 
    @isDiscount4Dish = 0
select * from invoice where id = 15
--OK

--======================================================================================
--sp_SubmitOrder: OK

exec sp_SubmitOrder 
    @invoiceId = 14
--ERR_NO_ONLINE_DISH

exec sp_SubmitOrder 
    @invoiceId = 2
--ERR_INVALID_STATUS

exec sp_SubmitOrder 
    @invoiceId = 25
--OK, status từ 0 -> 1
select * from invoice where id = 25

--======================================================================================
--sp_CancelOrder: báo lỗi sai với invoice id ko tồn tại

exec sp_CancelOrder 
    @invoiceId = 1
select * from invoice
--OK

exec sp_CancelOrder 
    @invoiceId = 2
--ERR_INVALID_STATUS

exec sp_CancelOrder 
    @invoiceId = 30
--ERR_INVALID_STATUS -> báo lỗi sai
select * from InvoiceDetail

--======================================================================================
--sp_AcceptOrder: báo lỗi sai với invoice id ko tồn tại
exec sp_AcceptOrder 
    @invoiceId = 1,
	@employeeId = 1
select * from invoice
--ERR_INVALID_STATUS

update invoice 
set status = 1
where id = 1

exec sp_AcceptOrder 
    @invoiceId = 1,
	@employeeId = 1
select * from invoice
--OK

--chuyển status về 1 trước
exec sp_AcceptOrder 
    @invoiceId = 1,
	@employeeId = 20
--OK, ko có emp này, báo lỗi khóa ngoại
select * from invoice

exec sp_AcceptOrder 
    @invoiceId = 40,
	@employeeId = 1
--ERR_INVALID_STATUS -> báo lỗi sai

--======================================================================================
--sp_AssignOrder2Table: OK??
select * from BranchTable
INSERT INTO BranchTable (branch, tbl, invoice) VALUES (1, 1, 1)

exec sp_AssignOrder2Table @invoiceId = 1, @tbl = 1, @employeeId = 1
--ERR_TABLE_NOT_EMPTY

exec sp_AssignOrder2Table @invoiceId = 2, @tbl = 2, @employeeId = 1
--Lỗi: không gán vào branchtable

exec sp_AssignOrder2Table @invoiceId = null, @tbl = 2, @employeeId = 1
--Lỗi: Explicit value must be specified for identity column in table 'Invoice' either when IDENTITY_INSERT is set to ON or when a replication user is inserting into a NOT FOR REPLICATION identity column.
--Fix: cần phải tắt identity

SET IDENTITY_INSERT invoice off 
exec sp_AssignOrder2Table @invoiceId = null, @tbl = 2, @employeeId = 1
--Lỗi: vẫn không gán vào branchtable, trả về (1 row affected) (0 rows affected)
--Check: không có insert, chỉ có update, ban đầu bàn là bảng này tự fill, chỉ update id nên vẫn ok

INSERT INTO BranchTable (branch, tbl, invoice) VALUES (1, 2, null)
exec sp_AssignOrder2Table @invoiceId = 2, @tbl = 2, @employeeId = 3
select * from BranchTable
--OK

--======================================================================================
--sp_IssueInvoice: OK

select * from invoice
exec sp_IssueInvoice @invoiceId = 3
--OK, status 3 -> 4

--status = 2
exec sp_IssueInvoice @invoiceId = 4
--ERR_INVALID_STATUS

--======================================================================================
--sp_ConfirmPayment: Lỗi line 608, 609. LỖI NẶNG

select * from invoice
select * from BranchTable
exec sp_AssignOrder2Table @invoiceId = 1, @tbl = 1, @employeeId = 1
exec sp_ConfirmPayment @invoiceId = 1, @tbl = 1
--Lỗi: The UPDATE statement conflicted with the CHECK constraint "CK__Invoice__status__01142BA1". The conflict occurred in database "SSMORI", table "dbo.Invoice", column 'status'
--Lỗi: Không cập nhật được status nhưng đã xóa invoice ra khỏi branch table

--status = 2
exec sp_ConfirmPayment @invoiceId = 4, @tbl = 1
--ERR_INVALID_STATUS

--status = 4
exec sp_ConfirmPayment @invoiceId = 3, @tbl = 1
--ERR_TABLE_INVOICE_MISMATCH, nhưng vẫn đang cập nhật cái gì đấy??

--======================================================================================
--sp_CreateReview: Lỗi constraint của status trong invoice thiếu 5, phải fix trong file table. OK??
exec sp_CreateReview 
    @invoiceId = 1,
    @service = 5,
    @quality = 4,
    @price = 3,
    @location = 4,
    @comment = N'TEST!'
--ERR_INVALID_STATUS

--Lỗi: lỗi trong table, status thiếu 5
--ALTER TABLE Invoice
--ADD CONSTRAINT CK_Invoice_Status
--CHECK (status IN (0, 1, 2, 3, 4, 5, 6))
update invoice
set status = 5
where id = 15
select * from invoice
select * from review
exec sp_CreateReview 
    @invoiceId = 15,
    @service = 5,
    @quality = 4,
    @price = 3,
    @location = 4,
    @comment = N'TEST!'
--Lỗi: invoice 15 ko có employee nên không thể thêm vào, tuy nhiên vẫn ghi nhận review
--Cannot insert the value NULL into column 'employee', table 'SSMORI.dbo.StaticsRateEmployeeDate'; column does not allow nulls. UPDATE fails.

exec sp_CreateReview 
    @invoiceId = 15,
    @service = 5,
    @quality = 4,
    @price = 3,
    @location = 4,
    @comment = N'TEST!'
--ERR_REVIEWED

update invoice
set status = 5
where id = 20
exec sp_CreateReview 
    @invoiceId = 20,
    @service = 5,
    @quality = 4,
    @price = 3,
    @location = 4,
    @comment = N'TEST!'
select * from StaticsRateEmployeeDate
--OK

--===================================================================================================================================================
--file trigger: Lỗi nặng
--trg_StaticsRevenueDate_UpdateStaticsRevenueMonth: Lỗi nặng, không có record được thêm vào StaticsRevenueMonth

select * from StaticsRevenueDate
select * from StaticsRevenueMonth
insert into StaticsRevenueDate (branch, date, totalInvoice, totalValue)
values (1, '2024-12-02', 5, 5000)
select * from StaticsRevenueMonth
--Lỗi: Không check future date
--Lỗi: không thấy cập nhật StaticsRevenueMonth, bảng này null


-- Update dữ liệu trong StaticsRevenueDate
update StaticsRevenueDate
set totalValue = 7000
where branch = 1 AND date = '2024-12-02'
--Lỗi: không thấy cập nhật StaticsRevenueMonth, bảng này null

--======================================================================================
--trg_ComboDish_DeleteDish: Lỗi không insert được combodish (insert ko dc -> xóa ko dc)

select * from dish
insert into Dish (nameVN, nameJP, price) VALUES ('Test trgA', 'Test trgA', 100)
insert into Dish (nameVN, nameJP, price) VALUES ('Test trgB', 'Test trgB', 100)
select * from dish

insert into Dish (nameVN, nameJP, price) VALUES ('Test trgB', 'Test trgB', 100)
select * from ComboDish
insert into ComboDish (combo, dish) VALUES (1, 5)
--Lỗi: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ComboDish_Combo". The conflict occurred in database "SSMORI", table "dbo.Dish", column 'id'.

update dish 
set isCombo = 1
where id = 4 
insert into ComboDish (combo, dish) VALUES (1, 4)
SELECT * FROM Dish WHERE id = 4
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ComboDish_Combo". The conflict occurred in database "SSMORI", table "dbo.Dish", column 'id'

--Check lỗi: combo trong combodish phải nằm trong các thuộc tính có trong dish, nhưng dish không có (chỉ có isCombo là bit)