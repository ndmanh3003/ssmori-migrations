USE MASTER
GO

IF DB_ID('SSMORI') IS NOT NULL
DROP DATABASE SSMORI
GO
CREATE DATABASE SSMORI
GO 
USE SSMORI
GO

CREATE TABLE Region (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL
)

CREATE TABLE Branch (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) UNIQUE NOT NULL,
    address				NVARCHAR(255) UNIQUE NOT NULL,
    openTime			TIME NOT NULL,
    closeTime			TIME NOT NULL,
    phone				VARCHAR(15) UNIQUE NOT NULL,
    hasMotoPark			BIT DEFAULT 0,
    hasCarPark			BIT DEFAULT 0,
    canShip				BIT DEFAULT 0,

    region				INT NOT NULL,
	manager				INT,

    tableQuantity		TINYINT DEFAULT 0 NOT NULL CHECK (tableQuantity >= 0),
    floorQuantity		TINYINT DEFAULT 1 NOT NULL CHECK (floorQuantity >= 1),

    CONSTRAINT FK_Branch_Region FOREIGN KEY (region) REFERENCES Region(id) ON DELETE CASCADE,
    CONSTRAINT CK_Branch_WorkingTime CHECK (openTime < closeTime)
)

CREATE TABLE Department (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) UNIQUE NOT NULL,
    salary				DECIMAL(10, 2) NOT NULL CHECK (salary > 0)
)

CREATE TABLE Employee (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
    dob					DATE NOT NULL,
    gender				TINYINT CHECK (gender IN (0, 1, 2)) NOT NULL, -- 0: male, 1: female, 2: other
    startAt				DATE NOT NULL,
    endAt				DATE DEFAULT NULL,

	branch				INT,
    department          INT NOT NULL,

	CONSTRAINT FK_Employee_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE,
	CONSTRAINT FK_Employee_Department FOREIGN KEY (department) REFERENCES Department(id) ON DELETE CASCADE,
    CONSTRAINT CK_Employee_StartEndDate CHECK (endAt IS NULL OR startAt < endAt)
)

CREATE TABLE WorkHistory (
    employee			INT NOT NULL,

    startAt				DATE NOT NULL,
    endAt				DATE DEFAULT NULL,

    branch				INT NOT NULL,

    PRIMARY KEY (employee, startAt),
    CONSTRAINT FK_WorkHistory_Employee FOREIGN KEY (employee) REFERENCES Employee(id),
    CONSTRAINT FK_WorkHistory_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT CK_WorkHistory_Dates CHECK (endAt IS NULL OR startAt < endAt)
)

CREATE TABLE Customer (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
    cid					NVARCHAR(20) UNIQUE NOT NULL,
    phone				VARCHAR(15) UNIQUE NOT NULL,
    email				VARCHAR(100) UNIQUE NOT NULL CHECK(email LIKE '%@%.%'),
    gender				TINYINT CHECK (gender IN (0, 1, 2)) NOT NULL, -- 0: male, 1: female, 2: other
    type				TINYINT CHECK (type IN (0, 1, 2)) NOT NULL, -- 0: member, 1: silver, 2: gold
    point				INT DEFAULT 0 NOT NULL CHECK(point >= 0),
    upgradeAt			DATE CHECK (upgradeAt <= GETDATE())
)

CREATE TABLE Card (
    id					INT IDENTITY PRIMARY KEY,

    issueAt				DATE CHECK (issueAt <= GETDATE()),
    isClosed			BIT DEFAULT 0,

    employee			INT NOT NULL,
    customer			INT NOT NULL,

    CONSTRAINT FK_Card_Employee FOREIGN KEY (employee) REFERENCES Employee(id),
    CONSTRAINT FK_Card_Customer FOREIGN KEY (customer) REFERENCES Customer(id)
)

CREATE TABLE Dish (
    id					INT IDENTITY PRIMARY KEY,

	isCombo				BIT DEFAULT 0,
    nameVN				NVARCHAR(100) UNIQUE NOT NULL,
	nameJP				NVARCHAR(100) UNIQUE NOT NULL,
    description			NVARCHAR(255),
    price				DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    canShip				BIT DEFAULT 0,
    img					NVARCHAR(255)
)

CREATE TABLE Category (
    id					INT IDENTITY PRIMARY KEY,

	nameVN				NVARCHAR(100) UNIQUE NOT NULL,
	nameJP				NVARCHAR(100) UNIQUE NOT NULL,
)

CREATE TABLE CategoryDish (
	no					INT IDENTITY,
    category			INT NOT NULL,

    dish				INT NOT NULL,

    PRIMARY KEY (category, no),
    CONSTRAINT FK_CategoryDish_Category FOREIGN KEY (category) REFERENCES Category(id) ON DELETE CASCADE,
    CONSTRAINT FK_CategoryDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id) ON DELETE CASCADE
)

CREATE TABLE ComboDish (
	no					INT IDENTITY,
    combo				INT NOT NULL,

    dish				INT NOT NULL,
	quantity			TINYINT DEFAULT 1 CHECK (quantity >= 1) NOT NULL,

    PRIMARY KEY (combo, no),
    CONSTRAINT FK_ComboDish_Combo FOREIGN KEY (combo) REFERENCES Dish(id) ON DELETE CASCADE,
	CONSTRAINT FK_ComboDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id) ON DELETE NO ACTION,
	CONSTRAINT CK_ComboDish_NoSelfReference CHECK (combo != dish)
)

CREATE TABLE BranchDish (
    branch				INT NOT NULL,
    dish				INT NOT NULL,

    isServed			BIT DEFAULT 1,

    PRIMARY KEY (branch, dish),
    CONSTRAINT FK_BranchDish_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE,
    CONSTRAINT FK_BranchDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id) ON DELETE CASCADE
)


CREATE TABLE Invoice (
    id					INT IDENTITY PRIMARY KEY,

	-- odering, completed, submited, canceled, accepted, serving, issue, paid
    -- online: odering, completed, submited, canceled/accepted, serving, issue, paid
    -- reserve: odering, submited, canceled/accepted
    -- offline: odering, completed, submited, canceled/accepted, serving, issue, paid
    status              NVARCHAR(10) NOT NULL,
    orderAt				DATETIME NOT NULL CHECK (orderAt <= GETDATE()),

    total				DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (total >= 0),
    shipCost			DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipCost >= 0),
    dishDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (dishDiscount >= 0),
    shipDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipDiscount >= 0),
    totalPayment		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (totalPayment >= 0),

    customer			INT,
    employee			INT,
    branch				INT NOT NULL,
    isOnline			BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Invoice_Customer FOREIGN KEY (customer) REFERENCES Customer(id),
    CONSTRAINT FK_Invoice_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_Invoice_Employee FOREIGN KEY (employee) REFERENCES Employee(id),
    CONSTRAINT CK_Invoice_Discount CHECK (shipCost >= shipDiscount AND total >= dishDiscount)
)


CREATE TABLE BranchTable (
    branch				INT NOT NULL,
    tbl					INT NOT NULL,

    invoice				INT,

    PRIMARY KEY (branch, tbl),
    CONSTRAINT FK_BranchTable_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE,
    CONSTRAINT FK_BranchTable_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
);


CREATE TABLE InvoiceDetail (
    invoice				INT NOT NULL,
    dish				INT NOT NULL,

    quantity			TINYINT NOT NULL CHECK (quantity > 0),
    sum					DECIMAL(10, 2) NOT NULL CHECK (sum >= 0),

    PRIMARY KEY (invoice, dish),
    CONSTRAINT FK_InvoiceDetail_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id),
    CONSTRAINT FK_InvoiceDetail_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)

CREATE TABLE Discount (
	id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
    type				TINYINT NOT NULL CHECK (type IN (0, 1, 2, 3)), -- 0: per dish, 1: val dish, 2: per ship, 3: val ship
    minApply			DECIMAL(10, 2) NOT NULL CHECK (minApply >= 0),
    startAt				DATE NOT NULL,
    endAt				DATE,
	img					VARCHAR(255) NOT NULL,

	valueAll			DECIMAL(10, 2) CHECK (valueAll >= 0),
	valueMember			DECIMAL(10, 2) CHECK (valueMember >= 0),
	valueSilver			DECIMAL(10, 2) CHECK (valueSilver >= 0),
	valueGold			DECIMAL(10, 2) CHECK (valueGold >= 0),

	CONSTRAINT CK_Discount_Dates CHECK (endAt IS NULL OR endAt > startAt)
)

CREATE TABLE Review (
    invoice				INT PRIMARY KEY,

    service				TINYINT CHECK (service BETWEEN 1 AND 5),
    quality				TINYINT CHECK (quality BETWEEN 1 AND 5),
    price				TINYINT CHECK (price BETWEEN 1 AND 5),
    location			TINYINT CHECK (location BETWEEN 1 AND 5),
    comment				NVARCHAR(255),

    CONSTRAINT FK_Review_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
)

CREATE TABLE Const (
    costPerKm			DECIMAL(10, 2) NOT NULL CHECK (costPerKm >= 0),
    freeDistance		INT NOT NULL CHECK (freeDistance >= 0),
	phone				VARCHAR(15) NOT NULL
)

CREATE TABLE Stream (
    accessAt			DATETIME PRIMARY KEY,
    avgDuration			INT NOT NULL CHECK (avgDuration > 0),
    quantity			INT NOT NULL CHECK (quantity > 0)
)

CREATE TABLE InvoiceReserve (
    invoice				INT PRIMARY KEY,

    guestCount			INT NOT NULL CHECK (guestCount > 0),
    bookingAt			DATETIME NOT NULL CHECK (bookingAt > GETDATE()),
    phone				NVARCHAR(15) NOT NULL,

    CONSTRAINT FK_InvoiceReserve_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
)

CREATE TABLE InvoiceOnline (
    invoice				INT PRIMARY KEY,

    phone				NVARCHAR(15) NOT NULL,
    address				NVARCHAR(255) NOT NULL,
    distanceKm			INT NOT NULL CHECK (distanceKm >= 0),

    CONSTRAINT FK_InvoiceOnline_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
)


CREATE TABLE StaticsRevenueDate (
    branch              INT NOT NULL,
    date                DATE NOT NULL,

    totalInvoice        INT NOT NULL CHECK (totalInvoice >= 0),
    totalValue          DECIMAL(10, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueDate_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE
);


CREATE TABLE StaticsRevenueMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL, 

    totalInvoice        INT NOT NULL CHECK (totalInvoice >= 0),
    totalValue          DECIMAL(10, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE
);

CREATE TABLE StaticsDishMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL,
    dish                INT NOT NULL,
	
	totalDish           INT NOT NULL,

    PRIMARY KEY (branch, date, dish),
    CONSTRAINT FK_StaticsDishMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE,
    CONSTRAINT FK_StaticsDishMonth_Dish FOREIGN KEY (dish) REFERENCES Dish(id) ON DELETE CASCADE
);

CREATE TABLE StaticsRateEmployeeDate (
    employee            INT NOT NULL,
    date                DATE NOT NULL,

    rating1S            INT DEFAULT 0 CHECK (rating1S >= 0),
    rating2S            INT DEFAULT 0 CHECK (rating2S >= 0),
    rating3S            INT DEFAULT 0 CHECK (rating3S >= 0),
    rating4S            INT DEFAULT 0 CHECK (rating4S >= 0),
    rating5S            INT DEFAULT 0 CHECK (rating5S >= 0),

    PRIMARY KEY (employee, date),
    CONSTRAINT FK_StaticsRateEmployeeDate_Employee FOREIGN KEY (employee) REFERENCES Employee(id)
);

CREATE TABLE StaticsRateBranchDate (
    branch	            INT NOT NULL,
    date                DATE NOT NULL,

	avgService			DECIMAL(3, 2) CHECK (avgService BETWEEN 1 AND 5),
	avgQuality			DECIMAL(3, 2) CHECK (avgQuality BETWEEN 1 AND 5),
	avgPrice			DECIMAL(3, 2) CHECK (avgPrice BETWEEN 1 AND 5),
	avgLocation			DECIMAL(3, 2) CHECK (avgLocation BETWEEN 1 AND 5),

	totalReview			INT NOT NULL DEFAULT 0,

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRateBranchDate_Branch FOREIGN KEY (branch) REFERENCES Branch(id) ON DELETE CASCADE
);

CREATE TABLE OTP (
    phone			    VARCHAR(15) NOT NULL PRIMARY KEY,
    otp			        VARCHAR(6) NOT NULL,
    issueAt			    DATETIME NOT NULL, -- 30s for reissue, 3m for expire
    attempt			    TINYINT DEFAULT 0 NOT NULL CHECK (attempt >= 0 AND attempt <= 3),
    type                TINYINT CHECK (type IN (0, 3)) NOT NULL -- 0: customer, 1: employee, 2: branch, 3: system
)

ALTER TABLE Branch
ADD CONSTRAINT FK_Branch_Manager FOREIGN KEY (manager) REFERENCES Employee(id)
