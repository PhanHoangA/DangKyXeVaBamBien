USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'DangKyXeVaBamBienProject')
BEGIN
    CREATE DATABASE DangKyXeVaBamBienProject;
END
GO

USE DangKyXeVaBamBienProject;
GO

-- 1. Xóa các bảng cũ nếu đã tồn tại (để F5 lại không bị lỗi phụ thuộc khóa ngoại)
IF OBJECT_ID('dbo.[REGISTRATIONS]', 'U') IS NOT NULL DROP TABLE dbo.[REGISTRATIONS];
IF OBJECT_ID('dbo.[LICENSE_PLATES]', 'U') IS NOT NULL DROP TABLE dbo.[LICENSE_PLATES];
IF OBJECT_ID('dbo.[VEHICLES]', 'U') IS NOT NULL DROP TABLE dbo.[VEHICLES];
IF OBJECT_ID('dbo.[USERS]', 'U') IS NOT NULL DROP TABLE dbo.[USERS];
IF OBJECT_ID('dbo.[VEHICLE_TYPES]', 'U') IS NOT NULL DROP TABLE dbo.[VEHICLE_TYPES];
IF OBJECT_ID('dbo.[VEHICLE_BRANDS]', 'U') IS NOT NULL DROP TABLE dbo.[VEHICLE_BRANDS];
IF OBJECT_ID('dbo.[DISTRICTS]', 'U') IS NOT NULL DROP TABLE dbo.[DISTRICTS];
IF OBJECT_ID('dbo.[ROLES]', 'U') IS NOT NULL DROP TABLE dbo.[ROLES];
GO

-- ============================================================
-- 2. TẠO CÁC BẢNG (TABLE CREATION)
-- ============================================================

-- Bảng 1: Phân quyền vai trò
CREATE TABLE [dbo].[ROLES](
    [roleId] INT PRIMARY KEY IDENTITY(1,1),
    [roleName] NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 2: Danh mục Quận / Huyện & Đầu số biển
CREATE TABLE [dbo].[DISTRICTS](
    [districtId] INT PRIMARY KEY IDENTITY(1,1),
    [provinceName] NVARCHAR(100) NOT NULL,
    [districtName] NVARCHAR(100) NOT NULL,
    [platePrefix] NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 3: Tài khoản người dùng (Chủ xe, Cán bộ, Admin)
CREATE TABLE [dbo].[USERS](
    [userId] INT PRIMARY KEY IDENTITY(1,1),
    [userName] NVARCHAR(50) NOT NULL UNIQUE,
    [userpassword] NVARCHAR(255) NOT NULL,
    [fullName] NVARCHAR(100) NOT NULL,
    [identityCard] NVARCHAR(50) NOT NULL UNIQUE,
    [phone] VARCHAR(15) NOT NULL,
    [email] VARCHAR(100) NULL,
    [address] NVARCHAR(255) NOT NULL, -- Đã chuyển sang NVARCHAR để lưu tiếng Việt có dấu
    [districtId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[DISTRICTS]([districtId]),
    [roleId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[ROLES]([roleId]),
    [createAt] DATETIME DEFAULT GETDATE()
);
GO

-- Bảng 4: Hãng sản xuất xe
CREATE TABLE [dbo].[VEHICLE_BRANDS](
    [brandId] INT PRIMARY KEY IDENTITY(1,1),
    [brandName] NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Bảng 5: Phân loại xe (Xe số, Xe tay ga, Xe điện...)
CREATE TABLE [dbo].[VEHICLE_TYPES](
    [typeId] INT PRIMARY KEY IDENTITY(1,1),
    [typeName] NVARCHAR(50) NOT NULL,
    [capacityRange] NVARCHAR(50) NULL
);
GO

-- Bảng 6: Thông tin phương tiện xe máy
CREATE TABLE [dbo].[VEHICLES](
    [vehicleId] INT PRIMARY KEY IDENTITY(1,1),
    [ownerId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[USERS]([userId]),
    [brandId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[VEHICLE_BRANDS]([brandId]),
    [typeId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[VEHICLE_TYPES]([typeId]),
    [modelName] NVARCHAR(50) NOT NULL,
    [engineNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [chassisNumber] NVARCHAR(50) NOT NULL UNIQUE,
    [color] NVARCHAR(50) NOT NULL,
    [engineCapacity] INT NOT NULL,
    [vehicleValue] DECIMAL(12,2) NOT NULL,
    [taxReceiptNumber] VARCHAR(50) NOT NULL,
    [invoiceNumber] VARCHAR(50) NOT NULL,
    [createAt] DATETIME DEFAULT GETDATE()
);
GO

-- Bảng 7: Kho biển số theo từng địa bàn
CREATE TABLE [dbo].[LICENSE_PLATES](
    [plateId] INT PRIMARY KEY IDENTITY(1,1),
    [districtId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[DISTRICTS]([districtId]),
    [plateNumber] NVARCHAR(50) NOT NULL,
    [fullPlate] NVARCHAR(50) NOT NULL UNIQUE,
    [status] NVARCHAR(50) DEFAULT N'AVAILABLE' CHECK ([status] IN (N'AVAILABLE', N'ASSIGNED', N'BLOCKED')),
    [assignedAt] DATETIME NULL
);
GO

-- Index hỗ trợ quay biển số ngẫu nhiên siêu nhanh
CREATE INDEX idx_district_status ON [dbo].[LICENSE_PLATES] ([districtId], [status]);
GO

-- Bảng 8: Hồ sơ đăng ký và bấm biển số
CREATE TABLE [dbo].[REGISTRATIONS](
    [registrationId] INT PRIMARY KEY IDENTITY(1,1),
    [vehicleId] INT NOT NULL UNIQUE FOREIGN KEY REFERENCES [dbo].[VEHICLES]([vehicleId]),
    [ownerId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[USERS]([userId]),
    [districtId] INT NOT NULL FOREIGN KEY REFERENCES [dbo].[DISTRICTS]([districtId]),
    [plateId] INT NULL FOREIGN KEY REFERENCES [dbo].[LICENSE_PLATES]([plateId]),
    [officerId] INT NULL FOREIGN KEY REFERENCES [dbo].[USERS]([userId]),
    [drawCode] VARCHAR(20) NULL,
    [feeAmount] DECIMAL(10,2) NULL,
    [status] NVARCHAR(50) NOT NULL DEFAULT N'PENDING' CHECK ([status] IN (N'PENDING', N'APPROVED', N'DRAWN', N'REJECTED')),
    [rejectionReason] NVARCHAR(225) NULL,
    [submittedAt] DATETIME DEFAULT GETDATE(),
    [approvedAt] DATETIME NULL,
    [drawnAt] DATETIME NULL
);
GO

-- Filtered Unique Index: Trong SQL Server, cho phép nhiều dòng có drawCode = NULL khi chờ duyệt, nhưng khi đã cấp mã thì duy nhất
CREATE UNIQUE NONCLUSTERED INDEX UQ_REGISTRATIONS_drawCode ON [dbo].[REGISTRATIONS]([drawCode]) WHERE [drawCode] IS NOT NULL;
GO

-- ============================================================
-- 3. CHÈN DỮ LIỆU MẪU (SEED DATA FOR TESTING)
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
