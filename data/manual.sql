USE SSMORI
GO

DELETE FROM ComboDish
DELETE FROM CategoryDish
DELETE FROM BranchDish
DELETE FROM RegionDish
DELETE FROM Dish
DELETE FROM Category
DELETE FROM Branch
DELETE FROM Region
GO

DBCC CHECKIDENT ('Region', RESEED, 1)
DBCC CHECKIDENT ('Branch', RESEED, 1)
DBCC CHECKIDENT ('Category', RESEED, 1)
DBCC CHECKIDENT ('Dish', RESEED, 1)
GO

INSERT INTO Region (name) VALUES (N'Thành phố Hồ Chí Minh'), (N'Hà Nội'), (N'Đà Nẵng')
GO

INSERT INTO Branch (region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES 
(1, N'Mori Quận 1', N'123 Lê Lợi, Quận 1', N'8:00', N'22:00', 19001523, 0, 1, 1),
(1, N'Mori Thảo Điền', N'45 Nguyễn Văn Hưởng, Quận 2', N'8:00', N'22:00', 19001524, 1, 1, 0),
(1, N'Mori Quận 3', N'78 Võ Văn Tần, Quận 3', N'8:00', N'22:00', 19001525, 0, 1, 0),
(1, N'Mori Gò Vấp', N'112 Phạm Văn Chiêu, Quận Gò Vấp', N'8:00', N'22:00', 19001526, 1, 0, 1),
(1, N'Mori Phú Mỹ Hưng', N'90 Nguyễn Đức Cảnh, Quận 7', N'8:00', N'22:00', 19001527, 1, 0, 1),
(1, N'Mori Tân Bình', N'56 Hoàng Hoa Thám, Quận Tân Bình', N'8:00', N'22:00', 19001528, 1, 1, 1),
(1, N'Mori Bình Thạnh', N'34 Đinh Tiên Hoàng, Quận Bình Thạnh', N'8:00', N'22:00', 19001529, 0, 1, 1),
(2, N'Mori Hoàn Kiếm', N'25 Hàng Bạc, Quận Hoàn Kiếm', N'8:00', N'22:00', 19001530, 1, 0, 1),
(2, N'Mori Đống Đa', N'72 Tây Sơn, Quận Đống Đa', N'8:00', N'22:00', 19001531, 1, 1, 0),
(2, N'Mori Cầu Giấy', N'150 Trần Duy Hưng, Quận Cầu Giấy', N'8:00', N'22:00', 19001532, 1, 1, 1),
(2, N'Mori Long Biên', N'88 Ngọc Lâm, Quận Long Biên', N'8:00', N'22:00', 19001533, 0, 1, 1),
(2, N'Mori Hà Đông', N'105 Quang Trung, Quận Hà Đông', N'8:00', N'22:00', 19001534, 1, 0, 1),
(3, N'Mori Hải Châu', N'45 Nguyễn Văn Linh, Quận Hải Châu', N'8:00', N'22:00', 19001535, 1, 0, 1),
(3, N'Mori Sơn Trà', N'123 Võ Nguyên Giáp, Quận Sơn Trà', N'8:00', N'22:00', 19001536, 1, 1, 0),
(3, N'Mori Ngũ Hành Sơn', N'90 Trần Hưng Đạo, Quận Ngũ Hành Sơn', N'8:00', N'22:00', 19001537, 1, 0, 1);
GO

INSERT INTO Category (name) VALUES (N'Seafood'), (N'Tempura'), (N'Premium');
GO

INSERT INTO Dish (isCombo, canShip, nameVn, nameEn, price) VALUES
(0, 1, N'Cá ngừ đại dương', N'Ocean Tuna', 300000),
(0, 1, N'Cơm cuộn cá hồi tôm chiên', N'Salmon and Shrimp Tempura Rolls', 100000),
(0, 1, N'Cá hồi Na Uy', N'Norwegian Salmon', 350000),
(0, 1, N'Cơm cuộn lươn hun khói', N'Smoked Eel Roll', 120000),
(0, 1, N'Cá hồi sò điệp', N'Salmon and Scallops', 200000),
(0, 1, N'Bạch tuộc Nhật Bản', N'Japanese Octopus', 300000),
(0, 0, N'Tôm chiên bột tempura', N'Tempura Fried Shrimp', 150000),
(0, 1, N'Sò đỏ Nhật Bản', N'Japanese Red Clams', 250000),
(0, 1, N'Maki Cơm cuộn cá hồi', N'Salmon Maki Roll', 150000),
(0, 1, N'Lươn hun khói Nhật Bản', N'Smoked Japanese Eel', 200000),
(0, 0, N'Cá hồi và phô mai chiên giòn', N'Crispy Fried Salmon and Cheese', 150000),
(0, 1, N'Cá hồi trứng cá chuồn', N'Salmon and Fish Roe', 200000),
(0, 0, N'Tôm sú biển thiên nhiên', N'Natural Wild Sea Prawns', 300000),
(0, 1, N'Cá trích Nhật Bản', N'Japanese Herring', 150000),
(0, 0, N'Trứng cá chuồn Nhật Bản', N'Japanese Fish Roe', 400000),
(0, 1, N'Cá ngừ vây xanh Nhật Bản', N'Japanese Bluefin Tuna', 600000),
(0, 1, N'Gan cá sashimi', N'Sashimi Fish Liver', 150000),
(0, 1, N'Bạch tuộc trộn', N'Octopus Salad', 120000),
(0, 1, N'Cơm cuộn dưa leo', N'Cucumber Roll', 50000),
(0, 1, N'Cá Saba ngâm giấm', N'Vinegar-Pickled Saba Fish', 120000),
(1, 0, N'Hải sản thượng hạng', N'Seafood Deluxe', 1250000),
(1, 1, N'Tiệc cơm cuộn và tempura', N'Rolls and Tempura Feast', 500000);
GO

INSERT INTO CategoryDish (category, dish) VALUES
(1, 1),
(1, 3),
(1, 5),
(1, 6),
(1, 8),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 20),
(2, 2),
(2, 4),
(2, 7),
(2, 9),
(2, 11),
(2, 19),
(3, 1),
(3, 3),
(3, 6),
(3, 13),
(3, 15),
(3, 16);
GO

INSERT INTO ComboDish (combo, dish) VALUES 
(21, 1),
(21, 3),
(21, 6),
(21, 15),
(22, 2),
(22, 7),
(22, 9),
(22, 19);
GO

INSERT INTO RegionDish (region, dish) VALUES 
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22)
GO

INSERT INTO BranchDish (branch, dish) VALUES 
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(2, 8),
(2, 9),
(2, 10),
(2, 11),
(2, 12),
(2, 13),
(2, 14),
(2, 15),
(2, 16),
(2, 17),
(2, 18),
(2, 19),
(2, 20),
(2, 21),
(2, 22),
(3, 1),
(3, 2),
(3, 3),
(3, 4),
(3, 5),
(3, 6),
(3, 7),
(3, 8),
(3, 9),
(3, 10),
(3, 11),
(3, 12),
(3, 13),
(3, 14),
(3, 15),
(3, 16),
(3, 17),
(3, 18),
(3, 19),
(3, 20),
(3, 21),
(3, 22)
GO
