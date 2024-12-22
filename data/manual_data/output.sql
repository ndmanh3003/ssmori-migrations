DELETE FROM ComboDish;
DELETE FROM CategoryDish;
DELETE FROM Dish;
DELETE FROM Category;
DELETE FROM Branch;
DELETE FROM Region;
DBCC CHECKIDENT ('Region', RESEED, 0);
DBCC CHECKIDENT ('Branch', RESEED, 0);
DBCC CHECKIDENT ('Category', RESEED, 0);
DBCC CHECKIDENT ('Dish', RESEED, 0);
GO
SET IDENTITY_INSERT Region ON
INSERT INTO Region (id, name) VALUES (1, N'Thành phố Hồ Chí Minh');
INSERT INTO Region (id, name) VALUES (2, N'Hà Nội');
INSERT INTO Region (id, name) VALUES (3, N'Đà Nẵng');
SET IDENTITY_INSERT Region OFF
GO
SET IDENTITY_INSERT Branch ON
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (1, 1, N'Mori Quận 1', N'123 Lê Lợi, Quận 1', N'8:00', N'22:00', 19001523, 0, 1, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (2, 1, N'Mori Thảo Điền', N'45 Nguyễn Văn Hưởng, Quận 2', N'8:00', N'22:00', 19001524, 1, 1, 0);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (3, 1, N'Mori Quận 3', N'78 Võ Văn Tần, Quận 3', N'8:00', N'22:00', 19001525, 0, 1, 0);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (4, 1, N'Mori Gò Vấp', N'112 Phạm Văn Chiêu, Quận Gò Vấp', N'8:00', N'22:00', 19001526, 1, 0, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (5, 1, N'Mori Phú Mỹ Hưng', N'90 Nguyễn Đức Cảnh, Quận 7', N'8:00', N'22:00', 19001527, 1, 0, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (6, 1, N'Mori Tân Bình', N'56 Hoàng Hoa Thám, Quận Tân Bình', N'8:00', N'22:00', 19001528, 1, 1, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (7, 1, N'Mori Bình Thạnh', N'34 Đinh Tiên Hoàng, Quận Bình Thạnh', N'8:00', N'22:00', 19001529, 0, 1, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (8, 2, N'Mori Hoàn Kiếm', N'25 Hàng Bạc, Quận Hoàn Kiếm', N'8:00', N'22:00', 19001530, 1, 0, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (9, 2, N'Mori Đống Đa', N'72 Tây Sơn, Quận Đống Đa', N'8:00', N'22:00', 19001531, 1, 1, 0);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (10, 2, N'Mori Cầu Giấy', N'150 Trần Duy Hưng, Quận Cầu Giấy', N'8:00', N'22:00', 19001532, 1, 1, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (11, 2, N'Mori Long Biên', N'88 Ngọc Lâm, Quận Long Biên', N'8:00', N'22:00', 19001533, 0, 1, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (12, 2, N'Mori Hà Đông', N'105 Quang Trung, Quận Hà Đông', N'8:00', N'22:00', 19001534, 1, 0, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (13, 3, N'Mori Hải Châu', N'45 Nguyễn Văn Linh, Quận Hải Châu', N'8:00', N'22:00', 19001535, 1, 0, 1);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (14, 3, N'Mori Sơn Trà', N'123 Võ Nguyên Giáp, Quận Sơn Trà', N'8:00', N'22:00', 19001536, 1, 1, 0);
INSERT INTO Branch (id, region, name, address, openTime, closeTime, phone, hasMotoPark, hasCarPark, canShip) VALUES (15, 3, N'Mori Ngũ Hành Sơn', N'90 Trần Hưng Đạo, Quận Ngũ Hành Sơn', N'8:00', N'22:00', 19001537, 1, 0, 1);
SET IDENTITY_INSERT Branch OFF
GO
SET IDENTITY_INSERT Category ON
INSERT INTO Category (id, name) VALUES (1, N'Seafood');
INSERT INTO Category (id, name) VALUES (2, N'Tempura');
INSERT INTO Category (id, name) VALUES (3, N'Premium');
SET IDENTITY_INSERT Category OFF
GO
SET IDENTITY_INSERT Dish ON
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (1, 0, 1, N'Cá ngừ đại dương', N'Ocean Tuna', 300000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (2, 0, 1, N'Cơm cuộn cá hồi tôm chiên', N'Salmon and Shrimp Tempura Rolls', 100000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (3, 0, 1, N'Cá hồi Na Uy', N'Norwegian Salmon', 350000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (4, 0, 1, N'Cơm cuộn lươn hun khói', N'Smoked Eel Roll', 120000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (5, 0, 1, N'Cá hồi sò điệp', N'Salmon and Scallops', 200000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (6, 0, 1, N'Bạch tuộc Nhật Bản', N'Japanese Octopus', 300000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (7, 0, 0, N'Tôm chiên bột tempura', N'Tempura Fried Shrimp', 150000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (8, 0, 1, N'Sò đỏ Nhật Bản', N'Japanese Red Clams', 250000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (9, 0, 1, N'Maki Cơm cuộn cá hồi', N'Salmon Maki Roll', 150000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (10, 0, 1, N'Lươn hun khói Nhật Bản', N'Smoked Japanese Eel', 200000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (11, 0, 0, N'Cá hồi và phô mai chiên giòn', N'Crispy Fried Salmon and Cheese', 150000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (12, 0, 1, N'Cá hồi trứng cá chuồn', N'Salmon and Fish Roe', 200000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (13, 0, 0, N'Tôm sú biển thiên nhiên', N'Natural Wild Sea Prawns', 300000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (14, 0, 1, N'Cá trích Nhật Bản', N'Japanese Herring', 150000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (15, 0, 0, N'Trứng cá chuồn Nhật Bản', N'Japanese Fish Roe', 400000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (16, 0, 1, N'Cá ngừ vây xanh Nhật Bản', N'Japanese Bluefin Tuna', 600000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (17, 0, 1, N'Gan cá sashimi', N'Sashimi Fish Liver', 150000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (18, 0, 1, N'Bạch tuộc trộn', N'Octopus Salad', 120000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (19, 0, 1, N'Cơm cuộn dưa leo', N'Cucumber Roll', 50000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (20, 0, 1, N'Cá Saba ngâm giấm', N'Vinegar-Pickled Saba Fish', 120000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (21, 1, 0, N'Hải sản thượng hạng', N'Seafood Deluxe', 1250000);
INSERT INTO Dish (id, isCombo, canShip, nameVn, nameEn, price) VALUES (22, 1, 1, N'Tiệc cơm cuộn và tempura', N'Rolls and Tempura Feast', 500000);
SET IDENTITY_INSERT Dish OFF
GO
INSERT INTO CategoryDish (category, dish) VALUES (1, 1);
INSERT INTO CategoryDish (category, dish) VALUES (1, 3);
INSERT INTO CategoryDish (category, dish) VALUES (1, 5);
INSERT INTO CategoryDish (category, dish) VALUES (1, 6);
INSERT INTO CategoryDish (category, dish) VALUES (1, 8);
INSERT INTO CategoryDish (category, dish) VALUES (1, 13);
INSERT INTO CategoryDish (category, dish) VALUES (1, 14);
INSERT INTO CategoryDish (category, dish) VALUES (1, 15);
INSERT INTO CategoryDish (category, dish) VALUES (1, 16);
INSERT INTO CategoryDish (category, dish) VALUES (1, 20);
INSERT INTO CategoryDish (category, dish) VALUES (2, 2);
INSERT INTO CategoryDish (category, dish) VALUES (2, 4);
INSERT INTO CategoryDish (category, dish) VALUES (2, 7);
INSERT INTO CategoryDish (category, dish) VALUES (2, 9);
INSERT INTO CategoryDish (category, dish) VALUES (2, 11);
INSERT INTO CategoryDish (category, dish) VALUES (2, 19);
INSERT INTO CategoryDish (category, dish) VALUES (3, 1);
INSERT INTO CategoryDish (category, dish) VALUES (3, 3);
INSERT INTO CategoryDish (category, dish) VALUES (3, 6);
INSERT INTO CategoryDish (category, dish) VALUES (3, 13);
INSERT INTO CategoryDish (category, dish) VALUES (3, 15);
INSERT INTO CategoryDish (category, dish) VALUES (3, 16);
GO
INSERT INTO ComboDish (combo, dish) VALUES (21, 1);
INSERT INTO ComboDish (combo, dish) VALUES (21, 3);
INSERT INTO ComboDish (combo, dish) VALUES (21, 6);
INSERT INTO ComboDish (combo, dish) VALUES (21, 15);
INSERT INTO ComboDish (combo, dish) VALUES (22, 2);
INSERT INTO ComboDish (combo, dish) VALUES (22, 7);
INSERT INTO ComboDish (combo, dish) VALUES (22, 9);
INSERT INTO ComboDish (combo, dish) VALUES (22, 19);
GO