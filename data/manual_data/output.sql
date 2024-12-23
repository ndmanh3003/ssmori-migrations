USE SSMORI
GO

DELETE FROM ComboDish;
DELETE FROM CategoryDish;
DELETE FROM Category;
DELETE FROM Dish;
DELETE FROM Branch;
DELETE FROM Region;
GO

DBCC CHECKIDENT ('Region', RESEED, 0);
DBCC CHECKIDENT ('Branch', RESEED, 0);
DBCC CHECKIDENT ('Dish', RESEED, 0);
DBCC CHECKIDENT ('Category', RESEED, 0);
GO

INSERT INTO Region (name) VALUES 
(N'Thành phố Hồ Chí Minh'),
(N'Hà Nội'),
(N'Đà Nẵng');
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

INSERT INTO Dish (isCombo, canShip, nameVn, nameEn, price, img) VALUES 
(0, 1, N'Cá ngừ đại dương', N'Ocean Tuna', 300000, N'1KuVhTi60MggnmfFxbN8IAW9JXQAE7JcW'),
(0, 1, N'Cơm cuộn cá hồi, tôm chiên', N'Salmon and Shrimp Tempura Rolls', 100000, N'1w2Kbd0sFkWHDK6OdYBHCvVUpoJPIdYPO'),
(0, 1, N'Cá hồi Na Uy', N'Norwegian Salmon', 350000, N'1n546PGzrnLDU1uKkiTPkqtAcetKpQq5M'),
(0, 1, N'Cơm cuộn lươn hun khói', N'Smoked Eel Roll', 120000, N'1F0BhMf5fLn1Ei-OjJtnZPhcucIS8mXQj'),
(0, 1, N'Cá hồi, sò điệp', N'Salmon and Scallops', 200000, N'15Q_x28Y2yhCDLjE4kUQ9-f_7XTGQoLzm'),
(0, 1, N'Bạch tuộc Nhật Bản', N'Japanese Octopus', 300000, N'11Yrx-V6-IzvvMYCSAX9n7LGmejhrrUl8'),
(0, 0, N'Tôm chiên bột tempura', N'Tempura Fried Shrimp', 150000, N'1a0U3zicMnnF5cIVtY5fd4JF1nd1ucm3i'),
(0, 1, N'Sò đỏ Nhật Bản', N'Japanese Red Clams', 250000, N'1C75aomZTHySFyCnrsjTFkzMwGgoX4wkZ'),
(0, 1, N'Maki Cơm cuộn cá hồi', N'Salmon Maki Roll', 150000, N'1e1N4ogpmeapYioXaZFtPUnyC9tBa-Icd'),
(0, 1, N'Lươn hun khói Nhật Bản', N'Smoked Japanese Eel', 200000, N'1BRcW0cAjxBgfqEeiVfw7MVAW1HWB4dDp'),
(0, 0, N'Cá hồi và phô mai chiên giòn', N'Crispy Fried Salmon and Cheese', 150000, N'1hNRnKHGkimG_BY3ov-v_YXZBQkJwyGIP'),
(0, 1, N'Cá hồi, trứng cá chuồn', N'Salmon and Fish Roe', 200000, N'1cpOriYbrJaReSEFlK5F_hdugVRTFRBzU'),
(0, 0, N'Tôm sú biển thiên nhiên', N'Natural Wild Sea Prawns', 300000, N'1zijTnmOqQLiZLv4V-IcP90VOGDMahnQF'),
(0, 1, N'Cá trích Nhật Bản', N'Japanese Herring', 150000, N'1Wd51V9oLEhoh6eNRnTWRuvABUnai2laL'),
(0, 0, N'Trứng cá chuồn Nhật Bản', N'Japanese Fish Roe', 400000, N'1jxuba7RWfPMfiL8AzO6r6VN2qBbAnX4Z'),
(0, 1, N'Cá ngừ vây xanh Nhật Bản', N'Japanese Bluefin Tuna', 600000, N'1m0TZ9MgerpZYxpjPfaMQkt227j8s4Nzm'),
(0, 1, N'Gan cá sashimi', N'Sashimi Fish Liver', 150000, N'1Wj64yQy7e_l4x_WL33Phb_7fJxjJVIpx'),
(0, 1, N'Bạch tuộc trộn', N'Octopus Salad', 120000, N'1G-mb8spDyHSy9ky0YJA6-iaZ2MKVi-Ci'),
(0, 1, N'Cơm cuộn dưa leo', N'Cucumber Roll', 50000, N'1RYbrXjF8hyhtZ_3nPyEFqL85mJxeZpcj'),
(0, 1, N'Cá Saba ngâm giấm', N'Vinegar-Pickled Saba Fish', 120000, N'1C6yRBuLPtc17b6GCM-RyK5UAF3qi-sQO'),
(1, 0, N'Hải sản thượng hạng', N'Seafood Deluxe', 1250000, N'1LYiUuC-_TYW7L7mQ5qURg11ArlfBfHWj'),
(1, 1, N'Tiệc cơm cuộn và tempura', N'Rolls and Tempura Feast', 500000, N'1o8WHlLSc2gDv3KeOwtKeFLlT19tviuW6');
GO

INSERT INTO Category (name) VALUES 
(N'Seafood'),
(N'Tempura'),
(N'Premium');
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
