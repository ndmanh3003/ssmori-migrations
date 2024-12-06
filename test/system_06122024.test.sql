use SSMORI
--sp_UpdateSystemConstants: OK
EXEC sp_UpdateSystemConstants 
    @costPerKm = 10.50, 
    @freeDistance = 5, 
    @phone = '11111111', 
    @shipMemberDiscount = 5, 
    @shipSilverDiscount = 10, 
    @shipGoldDiscount = 15, 
    @dishMemberDiscount = 5, 
    @dishSilverDiscount = 10, 
    @dishGoldDiscount = 15
select * from const
--OK

--======================================================================
--sp_CreateRegion: OK
EXEC sp_CreateRegion @name = 'North Region'
EXEC sp_CreateRegion @name = 'South Region'
EXEC sp_CreateRegion @name = 'Mid Region'
select * from Region
--OK

EXEC sp_CreateRegion @name = null
--Insert fails, OK
--======================================================================
--sp_UpdateRegion: OK
--sp_UpdateRegion
EXEC sp_UpdateRegion @regionId = 1, @name = 'South Region upd';
--OK

EXEC sp_UpdateRegion @regionId = 4, @name = 'South Region upd';
--ERR_NO_REGION, OK

EXEC sp_UpdateRegion @regionId = 1, @name = null;
--OK

--======================================================================
--sp_DeleteRegion: OK
EXEC sp_CreateRegion @name = 'test delete'
select * from region

EXEC sp_DeleteRegion @regionId = 4
--ERR_NO_REGION, OK

EXEC sp_DeleteRegion @regionId = 6

EXEC sp_CreateBranch 
    @name = 'Branch test',
    @address = '123 sf St',
    @openTime = '08:00',
    @closeTime = '22:00',
    @phone = '2564',
    @hasMotoPark = 1,
    @hasCarPark = 1,
    @tableQuantity = 10,
    @floorQuantity = 2,
    @canShip = 1,
    @regionId = 6;
--OK
--======================================================================
--sp_CreateBranch: OK
EXEC sp_CreateBranch 
    @name = 'Branch A',
    @address = '123 Main St',
    @openTime = '08:00',
    @closeTime = '22:00',
    @phone = '9876543210',
    @hasMotoPark = 1,
    @hasCarPark = 1,
    @tableQuantity = 10,
    @floorQuantity = 2,
    @canShip = 1,
    @regionId = 1;
select * from branch

--======================================================================
--sp_UpdateBranch: OK
EXEC sp_UpdateBranch 
    @branchId = 1,
    @name = 'Branch A upd',
    @address = '456 Main St',
    @openTime = '09:00',
    @closeTime = '21:00',
    @phone = '0123456789',
    @hasMotoPark = 0,
    @hasCarPark = 1,
    @tableQuantity = 15,
    @floorQuantity = 3,
    @canShip = 0,
    @regionId = 2;
--ERR_NO_BRANCH, OK
delete from BranchTable

EXEC sp_UpdateBranch 
    @branchId = 2,
    @name = 'Branch A upd',
    @address = '456 Main St',
    @openTime = '09:00',
    @closeTime = '21:00',
    @phone = '0123456789',
    @hasMotoPark = 0,
    @hasCarPark = 1,
    @tableQuantity = 15,
    @floorQuantity = 3,
    @canShip = 0,
    @regionId = 2;
select * from branchtable
--OK

--======================================================================
--sp_DeleteBranch: OK
EXEC sp_CreateBranch 
    @name = 'Branch test',
    @address = '1234 Main St',
    @openTime = '08:00',
    @closeTime = '22:00',
    @phone = '12435676',
    @hasMotoPark = 1,
    @hasCarPark = 1,
    @tableQuantity = 5,
    @floorQuantity = 2,
    @canShip = 1,
    @regionId = 1;
EXEC sp_DeleteBranch @branchId = 6
--OK

EXEC sp_DeleteBranch @branchId = 5
--ERR_NO_BRANCH, OK

--======================================================================
--sp_CreateDepartment: OK
EXEC sp_CreateDepartment @name = 'bep', @salary = 8000
EXEC sp_CreateDepartment @name = 'pvu', @salary = 2400
EXEC sp_CreateDepartment @name = 'thu ngan', @salary = 5000
select * from Department

--======================================================================
--sp_UpdateDepartment: OK
EXEC sp_UpdateDepartment @departmentId = 1, @name = 'HR Department', @salary = 7000;
select * from Department

EXEC sp_UpdateDepartment @departmentId = 5, @name = 'HR Department', @salary = 7000;
--ERR_NO_DEPARTMENT, OK

--======================================================================
--sp_DeleteDepartment: LỖI KHÓA NGOẠI
EXEC sp_CreateDepartment @name = 'TEST', @salary = 5000

EXEC sp_DeleteDepartment @departmentId = 4
--OK

EXEC sp_DeleteDepartment @departmentId = 5
--ERR_NO_DEPARTMENT, OK

--SAU KHI CÓ EMP
EXEC sp_DeleteDepartment @departmentId = 5
SELECT * FROM WorkHistory
SELECT * FROM Employee
SELECT * FROM department
--LỖI KHÓA NGOẠI
--======================================================================
--sp_CreateEmployee: OK
EXEC sp_CreateEmployee 
    @name = 'FAKER',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 1;
EXEC sp_CreateEmployee 
    @name = 'GUMAYUSI',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 1;
EXEC sp_CreateEmployee 
    @name = 'KERIA',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 2;
EXEC sp_CreateEmployee 
    @name = 'DORAN',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 2;
EXEC sp_CreateEmployee 
    @name = 'DORAN',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 3;
SELECT * FROM Employee
SELECT * FROM WorkHistory

EXEC sp_CreateEmployee 
    @name = 'DORAN',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 6,
    @department = 3;
--ERR_NO_BRANCH, OK

EXEC sp_CreateEmployee 
    @name = 'DORAN',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department =6;
--ERR_NO_DEPARTMENT, OK

EXEC sp_CreateEmployee 
    @name = 'GEN G',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 5

EXEC sp_CreateEmployee 
    @name = 'LPL',
    @dob = '1990-01-01',
    @gender = 'M',
    @startAt = '2024-01-01',
    @branch = 2,
    @department = 5

--sp_UpdateEmployee:
EXEC sp_UpdateEmployee 
    @employeeId = 1,
    @name = 'Jane Doe',
    @dob = '1995-05-05',
    @gender = 'F',
    @branch = 2,
    @department = 2;


--sp_LayOffEmployee: OK
EXEC sp_LayOffEmployee @employeeId = 7
SELECT * FROM Employee
SELECT * FROM WorkHistory
--OK

EXEC sp_LayOffEmployee @employeeId = 8
--ERR_NO_EMPLOYEE, OK

SELECT 
    fk.name AS FK_name,
    tp.name AS parent_table,
    ref.name AS referenced_table,
    c1.name AS parent_column,
    c2.name AS referenced_column
FROM 
    sys.foreign_keys fk
JOIN 
    sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN 
    sys.tables ref ON fk.referenced_object_id = ref.object_id
JOIN 
    sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
JOIN 
    sys.columns c1 ON fkc.parent_column_id = c1.column_id AND c1.object_id = tp.object_id
JOIN 
    sys.columns c2 ON fkc.referenced_column_id = c2.column_id AND c2.object_id = ref.object_id
WHERE 
    tp.name = 'WorkHistory';  -- Thay 'YourTableName' bằng tên bảng của bạn
