USE SSMORI
GO

select * from invoice
select * from invoiceonline
select * from invoicedetail
select * from StaticsRevenueMonth

delete from invoiceonline
delete from invoicedetail
delete from invoicereserve

delete from StaticsDishMonth
delete from StaticsRevenueMonth
delete from StaticsRevenueDate

delete from invoice

DBCC CHECKIDENT ('invoice', RESEED, 0)