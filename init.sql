USE MASTER;
GO

IF DB_ID('SSMORI') IS NOT NULL
BEGIN
    ALTER DATABASE SSMORI SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SSMORI;
END
GO

CREATE DATABASE SSMORI;
GO

USE SSMORI;
GO
