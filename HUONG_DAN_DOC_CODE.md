# HƯỚNG DẪN ĐỌC HIỂU TOÀN BỘ MÃ NGUỒN (CODEBASE READING GUIDE)

> **Dự án:** Hệ thống Đăng ký Phương tiện và Bấm Biển số Xe máy Trực tuyến (*Online Vehicle Registration & Plate Allocation Portal*)  
> **Cơ sở dữ liệu:** Microsoft SQL Server (`DangKyXeVaBamBienProject`)  
> **Kiến trúc:** Mô hình chuẩn **MVC2** (Model - View - Controller) sử dụng Java Servlet, JSP/JSTL, JDBC thuần.  
> **Căn cứ pháp lý:** Thông tư 24/2023/TT-BCA (Biển số định danh) và Thông tư 60/2023/TT-BTC (Lệ phí cấp biển).

---

## 📌 MỤC LỤC
1. [Nguyên Tắc Tiếp Cận Codebase Hiệu Quả](#1-nguyên-tắc-tiếp-cận-codebase-hiệu-quả)
2. [Sơ Đồ Lộ Trình Đọc 5 Bước Chuẩn](#2-sơ-đồ-lộ-trình-đọc-5-bước-chuẩn)
3. [Chi Tiết Từng Bước Đọc Mã Nguồn](#3-chi-tiết-từng-bước-đọc-mã-nguồn)
   - [Bước 1: Nắm bắt Nghiệp vụ & Căn cứ Pháp lý](#bước-1-nắm-bắt-nghiệp-vụ--căn-cứ-pháp-lý)
   - [Bước 2: Cấu trúc CSDL & Tầng Model (Entities)](#bước-2-cấu-trúc-csdl--tầng-model-entities)
   - [Bước 3: Bản đồ Điều hướng Hệ thống (web.xml)](#bước-3-bản-đồ-điều-hướng-hệ-thống-webxml)
   - [Bước 4: Đọc theo 5 Luồng Nghiệp vụ Cốt lõi](#bước-4-đọc-theo-5-luồng-nghiệp-vụ-cốt-lõi)
   - [Bước 5: Nắm chắc 3 Trọng tâm Kỹ thuật Phản biện](#bước-5-nắm-chắc-3-trọng-tâm-kỹ-thuật-phản-biện)
4. [Bảng Tra Cứu Nhanh (URL Matrix)](#4-bảng-tra-cứu-nhanh-url-matrix)

---

## 1. NGUYÊN TẮC TIẾP CẬN CODEBASE HIỆU QUẢ

Khi đọc một dự án Web MVC2 trong Java, **tuyệt đối không đọc file theo thứ tự bảng chữ cái**. Hãy áp dụng nguyên tắc:

> **"BÁM THEO MỘT CÚ CLICK CHUỘT CỦA NGƯỜI DÙNG (TRACE THE REQUEST FLOW)"**  
> `User Click Form/URL` $\longrightarrow$ `web.xml (Routing)` $\longrightarrow$ `Controller (Servlet)` $\longrightarrow$ `DAO & DB (Data Access)` $\longrightarrow$ `Forward về View (JSP)`

---

## 2. SƠ ĐỒ LỘ TRÌNH ĐỌC 5 BƯỚC CHUẨN

```text
       ┌────────────────────────────────────────────────────────┐
       │ BƯỚC 1: Đọc Tài Liệu Nghiệp Vụ (SRS.md & DB Spec)     │
       │ ➔ Hiểu bài toán hành chính công, vai trò & quy tắc BR   │
       └───────────────────────────┬────────────────────────────┘
                                   │
                                   ▼
       ┌────────────────────────────────────────────────────────┐
       │ BƯỚC 2: CSDL & Tầng Thực Thể (SQL Schema & Models)     │
       │ ➔ Hiểu 8 bảng dữ liệu & quan hệ các Class POJO Java     │
       └───────────────────────────┬────────────────────────────┘
                                   │
                                   ▼
       ┌────────────────────────────────────────────────────────┐
       │ BƯỚC 3: Bản Đồ Điều Hướng Hệ Thống (web.xml)           │
       │ ➔ Nắm toàn bộ URL Patterns và ánh xạ tới Servlets      │
       └───────────────────────────┬────────────────────────────┘
                                   │
                                   ▼
       ┌────────────────────────────────────────────────────────┐
       │ BƯỚC 4: Đọc 5 Luồng Nghiệp Vụ Chính (End-to-End)       │
       │ 1. Xác thực ➔ 2. Nộp xe ➔ 3. Duyệt ➔ 4. Bấm ➔ 5. Admin│
       └───────────────────────────┬────────────────────────────┘
                                   │
                                   ▼
       ┌────────────────────────────────────────────────────────┐
       │ BƯỚC 5: Trọng Tâm Kỹ Thuật (Transaction & Concurrency) │
       │ ➔ Khóa dòng UPDLOCK, mã Draw Code, bảo mật WEB-INF     │
       └────────────────────────────────────────────────────────┘
```

---

## 3. CHI TIẾT TỪNG BƯỚC ĐỌC MÃ NGUỒN

### Bước 1: Nắm bắt Nghiệp vụ & Căn cứ Pháp lý
Hiểu bài toán trước khi đọc code giúp bạn không bị lạc giữa hàng nghìn dòng lệnh.

1. **Đọc [SRS.md](file:///d:/Lab211/DangKyXeVaBamBienProject/SRS.md)** *(Đọc kỹ mục 1, 3, 4)*:
   - Hiểu 3 vai trò: `ROLE_USER` (Công dân), `ROLE_OFFICER` (Cán bộ CSGT), `ROLE_ADMIN` (Quản trị viên).
   - Nắm **Ma trận Quy tắc Nghiệp vụ (Business Rules)**:
     - `BR-01 (Khóa vùng địa lý)`: Công dân quận nào bốc biển số kho quận đó; Cán bộ quận nào duyệt xe quận đó.
     - `BR-02 (Duy nhất phương tiện)`: Số khung (VIN) và số máy là duy nhất toàn quốc; 1 xe chỉ gắn 1 hồ sơ.
     - `BR-03 (Chuyển đổi trạng thái)`: `PENDING` $\rightarrow$ `APPROVED` $\rightarrow$ `DRAWN` (hoặc `REJECTED`).
2. **Đọc [database_specification.md](file:///d:/Lab211/DangKyXeVaBamBienProject/database_specification.md)**:
   - Nắm sơ đồ ERD quan hệ thực thể giữa 8 bảng dữ liệu.

---

### Bước 2: Cấu trúc CSDL & Tầng Model (Entities)

1. **Đọc [DangKyXeVaBamBienProject.sql](file:///d:/Lab211/DangKyXeVaBamBienProject/DangKyXeVaBamBienProject.sql)**:
   - Xem cấu trúc 8 bảng và ràng buộc:
     - `ROLES` (Danh mục vai trò: 1-Admin, 2-Officer, 3-User).
     - `DISTRICTS` (Quận/Huyện & Mã đầu biển `platePrefix` như `29-P1`, `59-T1`).
     - `USERS` (Tài khoản, CCCD 12 số duy nhất, địa chỉ, quận thường trú).
     - `VEHICLE_BRANDS` & `VEHICLE_TYPES` (Hãng xe & Phân loại xe máy).
     - `VEHICLES` (Số khung `chassisNumber` UNIQUE, số máy `engineNumber` UNIQUE, Hóa đơn VAT, Thuế trước bạ).
     - `LICENSE_PLATES` (Kho biển số theo Quận, trạng thái `AVAILABLE`, `ASSIGNED`, `BLOCKED`).
     - `REGISTRATIONS` (Hồ sơ đăng ký nối giữa Xe, Chủ xe, Biển số, Cán bộ duyệt; lưu `drawCode` và trạng thái).
2. **Đọc [DAL/DBContext.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAL/DBContext.java)**:
   - Xem cách kết nối JDBC thuần tới SQL Server cổng `1433`.
3. **Đọc các lớp Models tại [Project/src/java/Models/](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Models/)**:
   - [User.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Models/User.java): JavaBean lưu thông tin tài khoản, quyền hạn và quận cư trú.
   - [Vehicle.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Models/Vehicle.java): JavaBean lưu thông số kỹ thuật xe và số hóa đơn VAT.
   - [Registration.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Models/Registration.java): JavaBean quản lý hồ sơ đăng ký và các hàm tiện ích (`isPending()`, `isApproved()`, `getStatusBadgeClass()`).
   - [LicensePlate.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Models/LicensePlate.java): Quản lý biển số và trạng thái.

---

### Bước 3: Bản đồ Điều hướng Hệ thống ([web.xml](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/web.xml))

Mở file [Project/web/WEB-INF/web.xml](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/web.xml):
- Đây là file cấu hình ánh xạ URL tới từng Controller.
- Chú ý: Toàn bộ file JSP nghiệp vụ đều nằm trong [`/WEB-INF/views/`](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/) để ngăn chặn truy cập trực tiếp từ trình duyệt, đảm bảo an toàn tuyệt đối.

---

### Bước 4: Đọc theo 5 Luồng Nghiệp vụ Cốt lõi

#### 🔹 Luồng 1: Đăng ký & Đăng nhập phân quyền (Authentication)
* **Đăng ký tài khoản công dân:**
  1. [RegisterController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/RegisterController.java): Xem cách bắt lỗi `identityCard` đúng 12 chữ số, số điện thoại, kiểm tra trùng username.
  2. [UserDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/UserDAO.java): Hàm `registerUser()` chèn dữ liệu vào bảng `USERS` với `roleId = 3`.
  3. [views/auth/register.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/auth/register.jsp): Giao diện chuẩn Cổng dịch vụ công quốc gia.
* **Đăng nhập & Rẽ nhánh:**
  1. [LoginController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/LoginController.java):
     - Xác thực `userName` và `userpassword`.
     - Lưu `currentUser` vào `HttpSession`.
     - **Rẽ nhánh theo Role**:
       - `ROLE_USER` $\rightarrow$ `/user/dashboard`
       - `ROLE_OFFICER` $\rightarrow$ `/officer/registrations`
       - `ROLE_ADMIN` $\rightarrow$ `/admin/license-plates`
  2. [views/auth/login.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/auth/login.jsp): Form đăng nhập.

---

#### 🔹 Luồng 2: Công dân Khai báo Xe & Nộp hồ sơ (Vehicle Registration)
* **Quy trình:**
  1. [VehicleFormController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/VehicleFormController.java):
     - `doGet`: Gọi `VehicleDAO.getAllBrands()` và `getAllTypes()` để đổ dữ liệu vào dropdown.
     - `doPost`: Kiểm tra giá trị xe `vehicleValue > 0`, kiểm tra trùng số khung (`isChassisNumberExists`) và số máy (`isEngineNumberExists`).
     - Tự động chuẩn hóa chữ in hoa (`toUpperCase()`) cho số khung, số máy, hóa đơn VAT.
  2. [VehicleDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/VehicleDAO.java) (Hàm `registerNewVehicle`):
     - **JDBC Transaction**: `connection.setAutoCommit(false)`.
     - Chèn vào `VEHICLES` lấy `generatedVehicleId` $\rightarrow$ Chèn vào `REGISTRATIONS` với trạng thái `'PENDING'` $\rightarrow$ `connection.commit()`.
  3. [views/user/vehicle-form.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/user/vehicle-form.jsp): Form khai báo thông số kỹ thuật và chứng từ hóa đơn VAT.
  4. [UserDashboardController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/UserDashboardController.java) & [views/user/dashboard.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/user/dashboard.jsp): Hiển thị danh sách hồ sơ của công dân kèm trạng thái và nút bấm biển.

---

#### 🔹 Luồng 3: Cán bộ CSGT Thẩm định Hồ sơ & Cấp Mã (Officer Review)
* **Quy trình:**
  1. [OfficerRegistrationsController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/OfficerRegistrationsController.java):
     - Lấy `currentUser.getDistrictId()`. Gọi `RegistrationDAO.getOfficerRegistrations(districtId, status, keyword)`.
     - **BR-01:** Đảm bảo cán bộ chỉ thấy hồ sơ thuộc đúng quận mình quản lý.
  2. [OfficerReviewController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/OfficerReviewController.java):
     - **Phê duyệt (`action=approve`)**: Cán bộ nhập mức lệ phí $\rightarrow$ Gọi `RegistrationDAO.approveRegistration()`.
       Hệ thống sinh ngẫu nhiên **Mã kích hoạt bấm biển (`DRAW-XXXXXX`)**, chuyển trạng thái sang `'APPROVED'`.
     - **Từ chối (`action=reject`)**: Cán bộ bắt buộc nhập lý do từ chối $\rightarrow$ Cập nhật trạng thái `'REJECTED'`.
  3. [views/officer/dashboard.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/officer/dashboard.jsp): Bàn làm việc thẩm định hồ sơ, modal duyệt và từ chối.

---

#### 🔹 Luồng 4: Công dân Bấm Biển Số Ngẫu Nhiên (Atomic Random Plate Draw)
*Đây là trái tim kỹ thuật của toàn bộ dự án, cần đọc kỹ nhất:*
1. [DrawPlateController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/DrawPlateController.java):
   - Nhận `registrationId` và mã `drawCode`.
   - Kiểm tra mã xác thực `drawCode` có trùng khớp với hồ sơ đang ở trạng thái `APPROVED` hay không.
2. [LicensePlateDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/LicensePlateDAO.java) (Hàm `drawRandomPlate`):
   - **Xử lý đồng thời (Concurrency Control)** bằng JDBC Transaction và khóa bản ghi SQL Server:
     ```sql
     SELECT TOP 1 plateId, plateNumber, fullPlate 
     FROM dbo.LICENSE_PLATES WITH (UPDLOCK, READPAST, ROWLOCK)
     WHERE districtId = ? AND status = N'AVAILABLE'
     ORDER BY NEWID();
     ```
   - Cập nhật biển số sang `'ASSIGNED'` (`assignedAt = GETDATE()`).
   - Cập nhật hồ sơ sang `'DRAWN'` (`drawnAt = GETDATE()`).
   - `connection.commit()`.
3. [views/user/draw-plate.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/user/draw-plate.jsp):
   - Chú ý đoạn JavaScript `<script>`: Gọi `fetch('/user/draw-plate')` bằng AJAX, nhận kết quả JSON và chạy hiệu ứng quay số 5 chữ số điện tử trong 2.5 giây.

---

#### 🔹 Luồng 5: Quản trị viên Khởi tạo Kho Biển Số (Admin Generator)
1. [AdminController.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/Controller/AdminController.java):
   - Nhận `districtId`, `startNumber`, `endNumber` và tùy chọn tự động khóa biển đẹp.
2. [LicensePlateDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/LicensePlateDAO.java) (Hàm `batchGeneratePlates`):
   - Dùng `PreparedStatement.addBatch()` và `executeBatch()` chèn hàng loạt hàng nghìn biển số.
   - Tự động nhận diện biển số đẹp (Ngũ quý `555.55`, `999.99` hoặc sảnh tiến `123.45`) để gán cờ `'BLOCKED'`, phục vụ đấu giá.
3. [views/admin/dashboard.jsp](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/web/WEB-INF/views/admin/dashboard.jsp): Giao diện quản lý kho biển.

---

### Bước 5: Nắm Chắc 3 Trọng Tâm Kỹ Thuật Phản Biện

Khi bảo vệ đồ án hoặc phỏng vấn, hãy chuẩn bị trả lời 3 câu hỏi kỹ thuật này:

1. **Khóa chống trùng biển khi nhiều người bấm cùng lúc:**
   - Chỉ vào câu lệnh `WITH (UPDLOCK, READPAST, ROWLOCK)` và `ORDER BY NEWID()` trong [LicensePlateDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/LicensePlateDAO.java).
2. **Đảm bảo toàn vẹn dữ liệu nộp xe:**
   - Chỉ vào Transaction với `setAutoCommit(false)` trong `registerNewVehicle()` ([VehicleDAO.java](file:///d:/Lab211/DangKyXeVaBamBienProject/Project/src/java/DAO/VehicleDAO.java)). Nếu bảng hồ sơ lỗi thì thông tin xe sẽ được `rollback()`, không tạo rác.
3. **Bảo mật thư mục View:**
   - Giải thích lý do đặt tất cả JSP trong `/WEB-INF/views/`: Người dùng gõ trực tiếp `localhost:9999/.../dashboard.jsp` sẽ bị chặn (404/403), bắt buộc phải đi qua Servlet Controller để kiểm tra Session và Role.

---

## 4. BẢNG TRA CỨU NHANH (URL MATRIX)

| URL Pattern | Controller (Servlet) | Tác nhân (Role) | Chức năng nghiệp vụ | Tầng DAO liên quan | View JSP hiển thị |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `/login` | `LoginController` | Tất cả | Đăng nhập & phân luồng theo vai trò | `UserDAO` | `/WEB-INF/views/auth/login.jsp` |
| `/register` | `RegisterController` | Khách vãng lai | Đăng ký tài khoản công dân (CCCD 12 số) | `UserDAO` | `/WEB-INF/views/auth/register.jsp` |
| `/logout` | `LogoutController` | Đã đăng nhập | Hủy session và thoát khỏi hệ thống | - | Chuyển hướng về `/home.jsp` |
| `/user/dashboard` | `UserDashboardController` | `ROLE_USER` | Xem danh sách xe & hồ sơ đã đăng ký | `RegistrationDAO` | `/WEB-INF/views/user/dashboard.jsp` |
| `/user/vehicle-form` | `VehicleFormController` | `ROLE_USER` | Kê khai thông số xe, hóa đơn VAT & nộp hồ sơ | `VehicleDAO` | `/WEB-INF/views/user/vehicle-form.jsp` |
| `/user/draw-plate` | `DrawPlateController` | `ROLE_USER` | Nhập mã Draw Code & bấm biển số ngẫu nhiên | `LicensePlateDAO` | `/WEB-INF/views/user/draw-plate.jsp` |
| `/officer/registrations` | `OfficerRegistrationsController` | `ROLE_OFFICER` | Bàn làm việc lọc & thẩm định hồ sơ theo địa bàn | `RegistrationDAO` | `/WEB-INF/views/officer/dashboard.jsp` |
| `/officer/review` | `OfficerReviewController` | `ROLE_OFFICER` | Phê duyệt (cấp mã Draw Code) hoặc Từ chối hồ sơ | `RegistrationDAO` | Chuyển hướng về `/officer/registrations` |
| `/admin/license-plates` | `AdminController` | `ROLE_ADMIN` | Sinh dải biển số hàng loạt & khóa/mở biển đẹp | `LicensePlateDAO` | `/WEB-INF/views/admin/dashboard.jsp` |
| `/admin/officers` | `AdminOfficersController` | `ROLE_ADMIN` | Quản lý danh sách tài khoản Cán bộ CSGT | `UserDAO` | `/WEB-INF/views/admin/officers.jsp` |

---
*Tài liệu được biên soạn đồng bộ với mã nguồn dự án [DangKyXeVaBamBienProject](file:///d:/Lab211/DangKyXeVaBamBienProject).*
