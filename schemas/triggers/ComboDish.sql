USE SSMORI
GO

-- ! Trigger xóa các món ăn trong combo khi món ăn bị xóa
CREATE OR ALTER TRIGGER trg_ComboDish_DeleteDish
ON Dish
AFTER DELETE
AS
BEGIN
    DELETE FROM ComboDish WHERE dish IN (SELECT id FROM deleted);
END;
