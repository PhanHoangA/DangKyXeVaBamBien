-- ============================================================
-- 3. CHÈN DỮ LIỆU MẪU (SEED DATA FOR MS SQL SERVER)
-- ============================================================

-- 3.1 Dữ liệu Vai trò
SET IDENTITY_INSERT dbo.[ROLES] ON;
INSERT INTO dbo.[ROLES] ([roleId], [roleName]) VALUES
(1, N'ROLE_ADMIN'),
(2, N'ROLE_OFFICER'),
(3, N'ROLE_USER');
SET IDENTITY_INSERT dbo.[ROLES] OFF;
GO

-- 3.2 Dữ liệu Quận / Huyện & Mã đầu biển
SET IDENTITY_INSERT dbo.[DISTRICTS] ON;
INSERT INTO dbo.[DISTRICTS] ([districtId], [provinceName], [districtName], [platePrefix]) VALUES
(1, N'Hà Nội', N'Quận Cầu Giấy', N'29-P1'),
(2, N'Hà Nội', N'Quận Đống Đa', N'29-E1'),
(3, N'TP. Hồ Chí Minh', N'Quận 1', N'59-T1'),
(4, N'Đà Nẵng', N'Quận Hải Châu', N'43-C1');
SET IDENTITY_INSERT dbo.[DISTRICTS] OFF;
GO

-- 3.3 Dữ liệu Hãng xe
SET IDENTITY_INSERT dbo.[VEHICLE_BRANDS] ON;
INSERT INTO dbo.[VEHICLE_BRANDS] ([brandId], [brandName]) VALUES
(1, N'Honda'),
(2, N'Yamaha'),
(3, N'Piaggio'),
(4, N'VinFast'),
(5, N'Suzuki');
SET IDENTITY_INSERT dbo.[VEHICLE_BRANDS] OFF;
GO

-- 3.4 Dữ liệu Loại xe
SET IDENTITY_INSERT dbo.[VEHICLE_TYPES] ON;
INSERT INTO dbo.[VEHICLE_TYPES] ([typeId], [typeName], [capacityRange]) VALUES
(1, N'Xe số', N'50cc - 175cc'),
(2, N'Xe tay ga', N'50cc - 175cc'),
(3, N'Xe máy điện', N'N/A'),
(4, N'Xe phân khối lớn', N'> 175cc');
SET IDENTITY_INSERT dbo.[VEHICLE_TYPES] OFF;
GO

-- 3.5 Dữ liệu Tài khoản (Mật khẩu mặc định: 123456)
SET IDENTITY_INSERT dbo.[USERS] ON;
INSERT INTO dbo.[USERS] ([userId], [userName], [userpassword], [fullName], [identityCard], [phone], [email], [address], [districtId], [roleId]) VALUES
(1, 'admin', '123456', N'Nguyễn Văn Quản Lý', '001090123456', '0901234567', 'admin@police.gov.vn', N'Số 47 Phạm Văn Đồng, Hà Nội', 1, 1),
(2, 'canbo_caugiay', '123456', N'Trần Văn Kiểm Duyệt', '001088654321', '0912345678', 'officer1@police.gov.vn', N'Công an Quận Cầu Giấy', 1, 2),
(3, 'nguyenvana', '123456', N'Nguyễn Văn A', '001201999888', '0987654321', 'nguyenvana@gmail.com', N'Số 12 Nguyễn Phong Sắc, Cầu Giấy', 1, 3);
SET IDENTITY_INSERT dbo.[USERS] OFF;
GO

-- 3.6 Dữ liệu Kho biển số khả dụng (Ví dụ cho Cầu Giấy 29-P1, Đống Đa 29-E1, Quận 1 59-T1)
INSERT INTO dbo.[LICENSE_PLATES] ([districtId], [plateNumber], [fullPlate], [status]) VALUES
(1, '123.45', N'29-P1 123.45', N'AVAILABLE'),
(1, '688.88', N'29-P1 688.88', N'AVAILABLE'),
(1, '999.99', N'29-P1 999.99', N'AVAILABLE'),
(1, '345.67', N'29-P1 345.67', N'AVAILABLE'),
(1, '555.55', N'29-P1 555.55', N'AVAILABLE'),
(1, '789.10', N'29-P1 789.10', N'AVAILABLE'),
(2, '111.11', N'29-E1 111.11', N'AVAILABLE'),
(3, '888.88', N'59-T1 888.88', N'AVAILABLE');
GO

-- 3.7 Dữ liệu Xe mẫu
SET IDENTITY_INSERT dbo.[VEHICLES] ON;
INSERT INTO dbo.[VEHICLES] ([vehicleId], [ownerId], [brandId], [typeId], [modelName], [engineNumber], [chassisNumber], [color], [engineCapacity], [vehicleValue], [taxReceiptNumber], [invoiceNumber]) VALUES
(1, 3, 1, 2, N'Honda SH 125i', 'JF51E-123456', 'RLHJF510M123456', N'Đen nhám', 125, 82000000.00, 'TB-2026-00192', 'VAT-2026-8812');
SET IDENTITY_INSERT dbo.[VEHICLES] OFF;
GO

-- 3.8 Dữ liệu Hồ sơ đăng ký mẫu (Đã duyệt, sẵn sàng bấm biển)
SET IDENTITY_INSERT dbo.[REGISTRATIONS] ON;
INSERT INTO dbo.[REGISTRATIONS] ([registrationId], [vehicleId], [ownerId], [districtId], [drawCode], [feeAmount], [status]) VALUES
(1, 1, 3, 1, 'DRAW-991823', 4000000.00, N'APPROVED');
SET IDENTITY_INSERT dbo.[REGISTRATIONS] OFF;
GO

