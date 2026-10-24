-- ============================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU FOR SQL SERVER (SSMS)
-- Dự án: Đăng ký và Bấm biển số xe máy (Java Servlet/JSP)
-- Hệ quản trị CSDL: Microsoft SQL Server (SSMS)
-- File: schema.sql
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'vehicle_registration_db')
BEGIN
    CREATE DATABASE vehicle_registration_db;
END
GO

USE vehicle_registration_db;
GO

-- 1. Xóa các bảng cũ nếu đã tồn tại (theo thứ tự phụ thuộc khóa ngoại)
IF OBJECT_ID('dbo.registrations', 'U') IS NOT NULL DROP TABLE dbo.registrations;
IF OBJECT_ID('dbo.license_plates', 'U') IS NOT NULL DROP TABLE dbo.license_plates;
IF OBJECT_ID('dbo.vehicles', 'U') IS NOT NULL DROP TABLE dbo.vehicles;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
IF OBJECT_ID('dbo.vehicle_types', 'U') IS NOT NULL DROP TABLE dbo.vehicle_types;
IF OBJECT_ID('dbo.vehicle_brands', 'U') IS NOT NULL DROP TABLE dbo.vehicle_brands;
IF OBJECT_ID('dbo.districts', 'U') IS NOT NULL DROP TABLE dbo.districts;
IF OBJECT_ID('dbo.roles', 'U') IS NOT NULL DROP TABLE dbo.roles;
GO

-- ============================================================
-- 2. TẠO CÁC BẢNG (TABLE CREATION - MS SQL SERVER T-SQL)
-- ============================================================

-- Bảng 1: Phân quyền vai trò
CREATE TABLE dbo.roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 2: Danh mục Quận/Huyện & Mã ký hiệu biển số
CREATE TABLE dbo.districts (
    district_id INT IDENTITY(1,1) PRIMARY KEY,
    province_name NVARCHAR(100) NOT NULL,
    district_name NVARCHAR(100) NOT NULL,
    plate_prefix NVARCHAR(10) NOT NULL UNIQUE
);
GO

-- Bảng 3: Tài khoản người dùng (Chủ xe, Cán bộ, Admin)
CREATE TABLE dbo.users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    identity_card VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NULL,
    address NVARCHAR(255) NOT NULL,
    district_id INT NOT NULL,
    role_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_users_district FOREIGN KEY (district_id) REFERENCES dbo.districts (district_id),
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES dbo.roles (role_id)
);
GO

-- Bảng 4: Hãng sản xuất xe
CREATE TABLE dbo.vehicle_brands (
    brand_id INT IDENTITY(1,1) PRIMARY KEY,
    brand_name NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 5: Phân loại xe (Xe số, Xe tay ga, Xe điện...)
CREATE TABLE dbo.vehicle_types (
    type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name NVARCHAR(50) NOT NULL,
    capacity_range NVARCHAR(50) NULL
);
GO

-- Bảng 6: Thông tin phương tiện xe máy
CREATE TABLE dbo.vehicles (
    vehicle_id INT IDENTITY(1,1) PRIMARY KEY,
    owner_id INT NOT NULL,
    brand_id INT NOT NULL,
    type_id INT NOT NULL,
    model_name NVARCHAR(100) NOT NULL,
    engine_number VARCHAR(50) NOT NULL UNIQUE,
    chassis_number VARCHAR(50) NOT NULL UNIQUE,
    color NVARCHAR(30) NOT NULL,
    engine_capacity INT NOT NULL,
    vehicle_value DECIMAL(12,2) NOT NULL,
    tax_receipt_number VARCHAR(50) NOT NULL,
    invoice_number VARCHAR(50) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_vehicles_owner FOREIGN KEY (owner_id) REFERENCES dbo.users (user_id),
    CONSTRAINT fk_vehicles_brand FOREIGN KEY (brand_id) REFERENCES dbo.vehicle_brands (brand_id),
    CONSTRAINT fk_vehicles_type FOREIGN KEY (type_id) REFERENCES dbo.vehicle_types (type_id)
);
GO

-- Bảng 7: Kho biển số theo từng địa bàn
CREATE TABLE dbo.license_plates (
    plate_id INT IDENTITY(1,1) PRIMARY KEY,
    district_id INT NOT NULL,
    plate_number VARCHAR(10) NOT NULL,
    full_plate NVARCHAR(20) NOT NULL UNIQUE,
    status NVARCHAR(20) NOT NULL DEFAULT N'AVAILABLE' CHECK (status IN (N'AVAILABLE', N'ASSIGNED', N'BLOCKED')),
    assigned_at DATETIME NULL,
    CONSTRAINT fk_plates_district FOREIGN KEY (district_id) REFERENCES dbo.districts (district_id)
);
GO

CREATE INDEX idx_district_status ON dbo.license_plates (district_id, status);
GO

-- Bảng 8: Hồ sơ đăng ký và bấm biển số
CREATE TABLE dbo.registrations (
    registration_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT NOT NULL UNIQUE,
    owner_id INT NOT NULL,
    district_id INT NOT NULL,
    plate_id INT NULL,
    officer_id INT NULL,
    draw_code VARCHAR(20) NULL,
    fee_amount DECIMAL(10,2) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'PENDING' CHECK (status IN (N'PENDING', N'APPROVED', N'DRAWN', N'REJECTED')),
    rejection_reason NVARCHAR(255) NULL,
    submitted_at DATETIME DEFAULT GETDATE(),
    approved_at DATETIME NULL,
    drawn_at DATETIME NULL,
    CONSTRAINT fk_reg_vehicle FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicles (vehicle_id),
    CONSTRAINT fk_reg_owner FOREIGN KEY (owner_id) REFERENCES dbo.users (user_id),
    CONSTRAINT fk_reg_district FOREIGN KEY (district_id) REFERENCES dbo.districts (district_id),
    CONSTRAINT fk_reg_plate FOREIGN KEY (plate_id) REFERENCES dbo.license_plates (plate_id),
    CONSTRAINT fk_reg_officer FOREIGN KEY (officer_id) REFERENCES dbo.users (user_id)
);
GO

-- Filtered Unique Index: Cho phép nhiều hồ sơ có draw_code = NULL khi chưa duyệt
CREATE UNIQUE NONCLUSTERED INDEX uq_registrations_draw_code ON dbo.registrations(draw_code) WHERE draw_code IS NOT NULL;
GO

-- ============================================================
-- 3. CHÈN DỮ LIỆU MẪU (SEED DATA FOR MS SQL SERVER)
-- ============================================================

-- 3.1 Dữ liệu Vai trò
SET IDENTITY_INSERT dbo.roles ON;
INSERT INTO dbo.roles (role_id, role_name) VALUES
(1, N'ROLE_ADMIN'),
(2, N'ROLE_OFFICER'),
(3, N'ROLE_USER');
SET IDENTITY_INSERT dbo.roles OFF;
GO

-- 3.2 Dữ liệu Quận / Huyện & Mã đầu biển
SET IDENTITY_INSERT dbo.districts ON;
INSERT INTO dbo.districts (district_id, province_name, district_name, plate_prefix) VALUES
(1, N'Hà Nội', N'Quận Cầu Giấy', N'29-P1'),
(2, N'Hà Nội', N'Quận Đống Đa', N'29-E1'),
(3, N'TP. Hồ Chí Minh', N'Quận 1', N'59-T1'),
(4, N'Đà Nẵng', N'Quận Hải Châu', N'43-C1');
SET IDENTITY_INSERT dbo.districts OFF;
GO

-- 3.3 Dữ liệu Hãng xe
SET IDENTITY_INSERT dbo.vehicle_brands ON;
INSERT INTO dbo.vehicle_brands (brand_id, brand_name) VALUES
(1, N'Honda'),
(2, N'Yamaha'),
(3, N'Piaggio'),
(4, N'VinFast'),
(5, N'Suzuki');
SET IDENTITY_INSERT dbo.vehicle_brands OFF;
GO

-- 3.4 Dữ liệu Loại xe
SET IDENTITY_INSERT dbo.vehicle_types ON;
INSERT INTO dbo.vehicle_types (type_id, type_name, capacity_range) VALUES
(1, N'Xe số', N'50cc - 175cc'),
(2, N'Xe tay ga', N'50cc - 175cc'),
(3, N'Xe máy điện', N'N/A'),
(4, N'Xe phân khối lớn', N'> 175cc');
SET IDENTITY_INSERT dbo.vehicle_types OFF;
GO

-- 3.5 Dữ liệu Tài khoản (Mật khẩu mặc định: 123456)
SET IDENTITY_INSERT dbo.users ON;
INSERT INTO dbo.users (user_id, username, password, full_name, identity_card, phone, email, address, district_id, role_id) VALUES
(1, 'admin', '123456', N'Nguyễn Văn Quản Lý', '001090123456', '0901234567', 'admin@police.gov.vn', N'Số 47 Phạm Văn Đồng, Hà Nội', 1, 1),
(2, 'canbo_caugiay', '123456', N'Trần Văn Kiểm Duyệt', '001088654321', '0912345678', 'officer1@police.gov.vn', N'Công an Quận Cầu Giấy', 1, 2),
(3, 'nguyenvana', '123456', N'Nguyễn Văn A', '001201999888', '0987654321', 'nguyenvana@gmail.com', N'Số 12 Nguyễn Phong Sắc, Cầu Giấy', 1, 3);
SET IDENTITY_INSERT dbo.users OFF;
GO

-- 3.6 Dữ liệu Kho biển số khả dụng (Ví dụ cho Cầu Giấy 29-P1, Đống Đa 29-E1, Quận 1 59-T1)
INSERT INTO dbo.license_plates (district_id, plate_number, full_plate, status) VALUES
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
SET IDENTITY_INSERT dbo.vehicles ON;
INSERT INTO dbo.vehicles (vehicle_id, owner_id, brand_id, type_id, model_name, engine_number, chassis_number, color, engine_capacity, vehicle_value, tax_receipt_number, invoice_number) VALUES
(1, 3, 1, 2, N'Honda SH 125i', 'JF51E-123456', 'RLHJF510M123456', N'Đen nhám', 125, 82000000.00, 'TB-2026-00192', 'VAT-2026-8812');
SET IDENTITY_INSERT dbo.vehicles OFF;
GO

-- 3.8 Dữ liệu Hồ sơ đăng ký mẫu (Đã duyệt, sẵn sàng bấm biển)
SET IDENTITY_INSERT dbo.registrations ON;
INSERT INTO dbo.registrations (registration_id, vehicle_id, owner_id, district_id, draw_code, fee_amount, status) VALUES
(1, 1, 3, 1, 'DRAW-991823', 4000000.00, N'APPROVED');
SET IDENTITY_INSERT dbo.registrations OFF;
GO
