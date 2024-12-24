USE SSMORI
GO

CREATE OR ALTER PROCEDURE sp_DownCustomersRank
AS
BEGIN
    DECLARE @CustomerID INT,
            @CustomerType CHAR(1),
            @CustomerPoint INT,
            @UpgradeAt DATE;

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

    FETCH NEXT FROM CustomerCursor INTO @CustomerID, @CustomerType, @CustomerPoint, @UpgradeAt;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Customer
        SET 
            type = CASE
                WHEN @CustomerType = 'S' THEN 'M'
                WHEN @CustomerType = 'G' THEN 'S'
            END,
            point = 0,
            upgradeAt = GETDATE()
        WHERE id = @CustomerID;

        FETCH NEXT FROM CustomerCursor INTO @CustomerID, @CustomerType, @CustomerPoint, @UpgradeAt;
    END

    CLOSE CustomerCursor;
    DEALLOCATE CustomerCursor;
END;
GO

