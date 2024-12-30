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
    img					NVARCHAR(255),
    openTime			TIME NOT NULL,
    closeTime			TIME NOT NULL,
    phone				VARCHAR(15) UNIQUE NOT NULL,
    hasMotoPark			BIT DEFAULT 0,
    hasCarPark			BIT DEFAULT 0,
    canShip				BIT DEFAULT 0,

    region				INT,
    isDeleted			BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Branch_Region FOREIGN KEY (region) REFERENCES Region(id) ON DELETE SET NULL,
)

CREATE TABLE Customer (
    id					INT IDENTITY PRIMARY KEY,

    name				NVARCHAR(100) NOT NULL,
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

    branch		    	INT NOT NULL,
    customer			INT NOT NULL,

    CONSTRAINT FK_Card_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_Card_Customer FOREIGN KEY (customer) REFERENCES Customer(id)
)

CREATE TABLE Dish (
    id					INT IDENTITY PRIMARY KEY,

	isCombo				BIT DEFAULT 0,
    nameVn				NVARCHAR(100) UNIQUE NOT NULL,
	nameEn				NVARCHAR(100) UNIQUE NOT NULL,
    price				DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    canShip				BIT DEFAULT 0,
    img					NVARCHAR(255),

    isDeleted            BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Category (
    id					INT IDENTITY PRIMARY KEY,

	name				NVARCHAR(100) UNIQUE NOT NULL,
)

CREATE TABLE CategoryDish (
    category			INT NOT NULL,
    dish				INT NOT NULL,

    PRIMARY KEY (category, dish),
    CONSTRAINT FK_CategoryDish_Category FOREIGN KEY (category) REFERENCES Category(id) ON DELETE CASCADE,
    CONSTRAINT FK_CategoryDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id),
)

CREATE TABLE ComboDish (
    combo				INT NOT NULL,
    dish				INT NOT NULL,

    PRIMARY KEY (combo, dish),
    CONSTRAINT FK_ComboDish_Combo FOREIGN KEY (combo) REFERENCES Dish(id),
	CONSTRAINT FK_ComboDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id),
	CONSTRAINT CK_ComboDish_NoSelfReference CHECK (combo <> dish)
)

CREATE TABLE BranchDish (
    branch				INT NOT NULL,
    dish				INT NOT NULL,

    PRIMARY KEY (branch, dish),
    CONSTRAINT FK_BranchDish_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_BranchDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)

CREATE TABLE RegionDish (
    region				INT NOT NULL,
    dish				INT NOT NULL,

    PRIMARY KEY (region, dish),
    CONSTRAINT FK_RegionDish_Region FOREIGN KEY (region) REFERENCES Region(id) ON DELETE CASCADE,
    CONSTRAINT FK_RegionDish_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)


CREATE TABLE Invoice (
    id					INT IDENTITY PRIMARY KEY,

    status              NVARCHAR(15) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'canceled', 'paid')),
    orderAt				DATETIME NOT NULL CHECK (orderAt <= GETDATE()),

    total				DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (total >= 0),
    shipCost			DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipCost >= 0),
    dishDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (dishDiscount >= 0),
    shipDiscount		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (shipDiscount >= 0),
    totalPayment		DECIMAL(10, 2) DEFAULT 0 NOT NULL CHECK (totalPayment >= 0),

    customer			INT,
    branch				INT NOT NULL,
    type    			CHAR(1) CHECK (type IN ('R', 'O', 'W')) NOT NULL, -- R: Reserve, O: Online, W: Walk-in

    CONSTRAINT FK_Invoice_Customer FOREIGN KEY (customer) REFERENCES Customer(id),
    CONSTRAINT FK_Invoice_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT CK_Invoice_Discount CHECK (shipCost >= shipDiscount AND total >= dishDiscount)
)

CREATE TABLE InvoiceDetail (
    invoice				INT NOT NULL,
    dish				INT NOT NULL,

    quantity			TINYINT NOT NULL CHECK (quantity > 0),
    sum					DECIMAL(10, 2) NOT NULL CHECK (sum >= 0),

    PRIMARY KEY (invoice, dish),
    CONSTRAINT FK_InvoiceDetail_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id),
    CONSTRAINT FK_InvoiceDetail_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)

CREATE TABLE InvoiceReserve (
    invoice				INT PRIMARY KEY,

    guestCount			INT NOT NULL CHECK (guestCount > 0),
    bookingAt			DATETIME NOT NULL CHECK (bookingAt > GETDATE()),

    CONSTRAINT FK_InvoiceReserve_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
)

CREATE TABLE InvoiceOnline (
    invoice				INT PRIMARY KEY,

    phone				NVARCHAR(15) NOT NULL,
    address				NVARCHAR(255) NOT NULL,
    distanceKm			INT NOT NULL CHECK (distanceKm >= 0),

    CONSTRAINT FK_InvoiceOnline_Invoice FOREIGN KEY (invoice) REFERENCES Invoice(id)
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
    id                  INT PRIMARY KEY CHECK (id = 1),

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

CREATE TABLE OTP (
    -- 6 digits OTP, 3 attempts, has 5 minutes to use, resend after 30 seconds
    phone			    VARCHAR(15) NOT NULL,
    otp			        VARBINARY(32) NOT NULL,
    expireAt		    DATETIME NOT NULL,
    attempt			    TINYINT DEFAULT 0 NOT NULL CHECK (attempt >= 0 AND attempt <= 3),
    type                CHAR(1) NOT NULL CHECK (type IN ('C', 'S', 'B', 'U')) -- C: Customer, S: System, B: Branch, U: Undefined

    PRIMARY KEY (phone, type)
)

CREATE TABLE StaticsRevenueDate (
    branch              INT NOT NULL,
    date                DATE NOT NULL,

    totalInvoice        INT NOT NULL CHECK (totalInvoice >= 0),
    totalValue          DECIMAL(10, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueDate_Branch FOREIGN KEY (branch) REFERENCES Branch(id)
)


CREATE TABLE StaticsRevenueMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL, 

    totalInvoice        INT NOT NULL CHECK (totalInvoice >= 0),
    totalValue          DECIMAL(12, 2) NOT NULL CHECK (totalValue >= 0),

    PRIMARY KEY (branch, date),
    CONSTRAINT FK_StaticsRevenueMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id)
)

CREATE TABLE StaticsDishMonth (
    branch              INT NOT NULL,
    date                DATE NOT NULL,
    dish                INT NOT NULL,
	
	totalDish           INT NOT NULL,

    PRIMARY KEY (branch, date, dish),
    CONSTRAINT FK_StaticsDishMonth_Branch FOREIGN KEY (branch) REFERENCES Branch(id),
    CONSTRAINT FK_StaticsDishMonth_Dish FOREIGN KEY (dish) REFERENCES Dish(id)
)

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
)
