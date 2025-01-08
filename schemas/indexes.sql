USE SSMORI
GO

CREATE INDEX IX_Invoice_Customer_OrderAt
ON Invoice(customer, orderAt)

CREATE INDEX IX_Invoice_Branch_OrderAt
ON Invoice(branch, orderAt)
INCLUDE (id, totalPayment)