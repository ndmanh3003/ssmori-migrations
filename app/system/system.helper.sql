CREATE OR ALTER TRIGGER trg_UpdateWorkHistoryEndAt
ON Employee
AFTER UPDATE
AS
BEGIN
    IF UPDATE(endAt)
    BEGIN
        -- Cập nhật endAt bên WorkHistory tương ứng với Employee được cập nhật
        UPDATE WH
        SET WH.endAt = E.endAt
        FROM WorkHistory WH
        INNER JOIN Inserted E ON WH.employee = E.id
        WHERE E.endAt IS NOT NULL;
    END
END
GO