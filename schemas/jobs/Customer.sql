USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_DownCustomersRank
AS
BEGIN
    DECLARE @customerID INT,
            @customerType CHAR(1),
            @customerPoint INT,
            @upgradeAt DATE;

    DECLARE CustomerCursor CURSOR FOR
        SELECT id, type, point, upgradeAt
        FROM Customer
        WHERE 
            DATEDIFF(DAY, upgradeAt, GETDATE()) > 365
            AND (
                (type = 'S' AND point < 50) OR 
                (type = 'G' AND point < 100)
            );

    OPEN CustomerCursor;

    FETCH NEXT FROM CustomerCursor INTO @customerID, @customerType, @customerPoint, @upgradeAt;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Customer
        SET 
            type = CASE
                WHEN @customerType = 'S' THEN 'M'
                WHEN @customerType = 'G' THEN 'S'
            END,
            point = 0,
            upgradeAt = GETDATE()
        WHERE id = @customerID;

        FETCH NEXT FROM CustomerCursor INTO @customerID, @customerType, @customerPoint, @upgradeAt;
    END

    CLOSE CustomerCursor;
    DEALLOCATE CustomerCursor;
END;
GO

