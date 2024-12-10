USE SSMORI
GO

CREATE TABLE Region (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) UNIQUE NOT NULL
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

    region				INT,
	manager				INT,

    tableQuantity		TINYINT DEFAULT 0 NOT NULL CHECK (tableQuantity >= 0),
    floorQuantity		TINYINT DEFAULT 1 NOT NULL CHECK (floorQuantity >= 1),

    isDeleted			BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Branch_Region FOREIGN KEY (region) REFERENCES Region(id) ON DELETE SET NULL,
    CONSTRAINT CK_Branch_WorkingTime CHECK (openTime < closeTime)
)

CREATE TABLE Department (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) UNIQUE NOT NULL,
    salary				DECIMAL(12, 2) NOT NULL CHECK (salary > 0)
)

CREATE TABLE Employee (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
    dob					DATE NOT NULL,
    gender				CHAR(1) CHECK (gender IN ('M', 'F', 'O')) NOT NULL, -- M: Male, F: Female, O: Other
    startAt				DATE NOT NULL,
    endAt				DATE DEFAULT NULL,
    phone               VARCHAR(15) UNIQUE NOT NULL,

	branch				INT NOT NULL,
    department          INT,

	CONSTRAINT FK_Employee_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
	CONSTRAINT FK_Employee_Department FOREIGN KEY (department) REFERENCES Department(id) ON DELETE SET NULL,
    CONSTRAINT CK_Employee_StartEndDate CHECK (endAt IS NULL OR startAt <= endAt)
)

CREATE TABLE WorkHistory (
    employee			INT NOT NULL,

    startAt				DATE NOT NULL,
    endAt				DATE DEFAULT NULL,

    branch				INT NOT NULL,

    PRIMARY KEY (employee, startAt),
    CONSTRAINT FK_WorkHistory_Employee FOREIGN KEY (employee) REFERENCES Employee(id),
    CONSTRAINT FK_WorkHistory_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT CK_WorkHistory_Dates CHECK (endAt IS NULL OR startAt <= endAt)
)

CREATE TABLE Customer (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
    cid					NVARCHAR(20) UNIQUE NOT NULL,
    phone				VARCHAR(15) UNIQUE NOT NULL,
    email				VARCHAR(100) UNIQUE NOT NULL CHECK(email LIKE '%@%.%'),
    gender				CHAR(1) CHECK (gender IN ('M', 'F', 'O')) NOT NULL, -- M: Male, F: Female, O: Other
    type				CHAR(1) CHECK (type IN ('M', 'S', 'G')) NOT NULL, -- M: Member, S: Silver, G: Gold
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
    img					NVARCHAR(255),

    isDeleted            BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Category (
    id					INT IDENTITY PRIMARY KEY,

	nameVN				NVARCHAR(100) UNIQUE NOT NULL,
	nameJP				NVARCHAR(100) UNIQUE NOT NULL,
)

CREATE TABLE CategoryDish (
    category			INT NOT NULL,
    dish				INT NOT NULL,

	no					TINYINT,

    PRIMARY KEY (category, dish),
    CONSTRAINT FK_CategoryDish_Category FOREIGN KEY (category) REFERENCES Category(id) ON DELETE CASCADE,
    CONSTRAINT FK_CategoryDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id),
)

CREATE TABLE ComboDish (
    combo				INT NOT NULL,
    dish				INT NOT NULL,

	no					TINYINT,

    PRIMARY KEY (combo, dish),
    CONSTRAINT FK_ComboDish_Combo FOREIGN KEY (combo) REFERENCES Dish(id),
	CONSTRAINT FK_ComboDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id),
	CONSTRAINT CK_ComboDish_NoSelfReference CHECK (combo != dish)
)

CREATE TABLE BranchDish (
    branch				INT NOT NULL,
    dish				INT NOT NULL,

    isServed			BIT DEFAULT 1,

    PRIMARY KEY (branch, dish),
    CONSTRAINT FK_BranchDish_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_BranchDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)


CREATE TABLE Invoice (
    id					INT IDENTITY PRIMARY KEY,

	-- odering, confirmed, in_progress, ready, discount_applied, paid, shipped, completed, canceled, waiting
    status              NVARCHAR(15) NOT NULL,
    orderAt				DATETIME NOT NULL CHECK (orderAt <= GETDATE()),

    total				DECIMAL(12, 2) DEFAULT 0 NOT NULL CHECK (total >= 0),
    shipCost			DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipCost >= 0),
    dishDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (dishDiscount >= 0),
    shipDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipDiscount >= 0),
    totalPayment		DECIMAL(12, 2) DEFAULT 0 NOT NULL CHECK (totalPayment >= 0),

    customer			INT,
    employee			INT,
    branch				INT,
    type    			CHAR(1) CHECK (type IN ('R', 'O', 'W')) NOT NULL, -- R: Reserve, O: Online, W: Walk-in

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
    CONSTRAINT FK_BranchTable_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
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
	phone				VARCHAR(15) NOT NULL,

    shipMemberDiscount	INT NOT NULL CHECK (shipMemberDiscount >= 0),
    shipSilverDiscount	INT NOT NULL CHECK (shipSilverDiscount >= 0),
    shipGoldDiscount	INT NOT NULL CHECK (shipGoldDiscount >= 0),

    dishMemberDiscount	INT NOT NULL CHECK (dishMemberDiscount >= 0),
    dishSilverDiscount	INT NOT NULL CHECK (dishSilverDiscount >= 0),
    dishGoldDiscount	INT NOT NULL CHECK (dishGoldDiscount >= 0),
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
    totalValue          DECIMAL(14, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueDate_Branch FOREIGN KEY (branch) REFERENCES Branch(id)
);


CREATE TABLE StaticsRevenueMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL, 

    totalInvoice        INT NOT NULL CHECK (totalInvoice >= 0),
    totalValue          DECIMAL(16, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id)
);

CREATE TABLE StaticsDishMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL,
    dish                INT NOT NULL,
	
	totalDish           INT NOT NULL,

    PRIMARY KEY (branch, date, dish),
    CONSTRAINT FK_StaticsDishMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_StaticsDishMonth_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
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
    CONSTRAINT FK_StaticsRateBranchDate_Branch FOREIGN KEY (branch) REFERENCES Branch(id)
);

CREATE TABLE OTP (
    phone			    VARCHAR(15) NOT NULL PRIMARY KEY,
    otp			        VARCHAR(6) NOT NULL,
    issueAt			    DATETIME NOT NULL,
    attempt			    TINYINT DEFAULT 0 NOT NULL CHECK (attempt >= 0 AND attempt <= 3),
    type                CHAR(1) NOT NULL CHECK (type IN ('E', 'C', 'S', 'B')) -- E: Employee, C: Customer, S: System, B: Branch
)

ALTER TABLE Branch
ADD CONSTRAINT FK_Branch_Manager FOREIGN KEY (manager) REFERENCES Employee(id)
