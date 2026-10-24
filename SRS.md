# TÀI LIỆU ĐẶC TẢ YÊU CẦU PHẦN MỀM (SRS)

**Tên dự án:** Hệ thống Đăng ký Phương tiện và Bấm Biển số Xe máy Trực tuyến (Online Vehicle Registration & License Plate Allocation System)  
**Mã cơ sở dữ liệu:** `DangKyXeVaBamBienProject`  
**Công nghệ sử dụng:** Java, Servlet, JSP, JSTL, JDBC, Microsoft SQL Server  
**Phiên bản:** 1.0  

---

## MỤC LỤC
1. [Giới thiệu (Introduction)](#1-giới-thiệu-introduction)
2. [Mô tả tổng quan (Overall Description)](#2-mô-tả-tổng-quan-overall-description)
3. [Đặc tả yêu cầu chức năng (Functional Requirements)](#3-đặc-tả-yêu-cầu-chức-năng-functional-requirements)
4. [Ma trận quy tắc nghiệp vụ (Business Rules)](#4-ma-trận-quy-tắc-nghiệp-vụ-business-rules)
5. [Yêu cầu phi chức năng (Non-Functional Requirements)](#5-yêu-cầu-phi-chức-năng-non-functional-requirements)
6. [Ma trận phân quyền truy cập (URL & Role Matrix)](#6-ma-trận-phân-quyền-truy-cập-url--role-matrix)
7. [Cấu trúc cơ sở dữ liệu & Ràng buộc (Database Mapping)](#7-cấu-trúc-cơ-sở-dữ-liệu--ràng-buộc-database-mapping)

---

## 1. GIỚI THIỆU (INTRODUCTION)

### 1.1. Mục đích (Purpose)
Tài liệu này mô tả chi tiết các yêu cầu chức năng (Functional Requirements), yêu cầu phi chức năng (Non-Functional Requirements), quy tắc nghiệp vụ (Business Rules) và ràng buộc thiết kế cho **Hệ thống Đăng ký xe và Bấm biển số trực tuyến**. Tài liệu là cơ sở thống nhất để đội ngũ phát triển thiết kế kiến trúc MVC2, lập trình Backend (Servlet/JDBC), giao diện (JSP/JSTL) và xây dựng kịch bản kiểm thử (Test Cases).

### 1.2. Phạm vi sản phẩm (Product Scope)
Hệ thống số hóa quy trình đăng ký xe máy theo địa bàn cấp Quận/Huyện, cho phép:
* **Công dân (`ROLE_USER`):** Khai báo hồ sơ phương tiện trực tuyến, theo dõi trạng thái xét duyệt, chỉnh sửa hồ sơ bị trả lại và thực hiện bấm biển số ngẫu nhiên bằng mã dự thưởng (`drawCode`).
* **Cán bộ CSGT (`ROLE_OFFICER`):** Tiếp nhận, đối chiếu thông tin phương tiện theo đúng địa bàn Quận/Huyện được phân công, phê duyệt hồ sơ (tính lệ phí và cấp mã bấm biển) hoặc từ chối kèm lý do.
* **Quản trị viên (`ROLE_ADMIN`):** Quản lý danh mục Quận/Huyện (`DISTRICTS`), Hãng xe (`VEHICLE_BRANDS`), Loại xe (`VEHICLE_TYPES`), quản lý người dùng và vận hành công cụ sinh kho biển số tự động (`LICENSE_PLATES`).

### 1.3. Thuật ngữ và Từ viết tắt (Definitions, Acronyms, and Abbreviations)

| Thuật ngữ / Viết tắt | Giải thích chi tiết |
| :--- | :--- |
| **MVC2** | Mô hình kiến trúc Web tách biệt: **Model** (JavaBeans/DAO/Service), **View** (JSP/JSTL), **Controller** (Java Servlet). |
| **Draw Code** | Mã xác thực gồm chuỗi ký tự duy nhất (VD: `DRAW-991823`) được hệ thống sinh tự động khi cán bộ phê duyệt hồ sơ, dùng để mở khóa tính năng bấm biển. |
| **Plate Prefix** | Mã đầu biển số gắn liền với một Quận/Huyện cụ thể (VD: `29-P1` cho Quận Cầu Giấy, `59-T1` cho Quận 1). |
| **Atomic Draw** | Thao tác rút biển số nguyên tử (sử dụng JDBC Transaction kết hợp khóa dòng SQL Server) đảm bảo không xảy ra trùng lặp biển số khi nhiều người bấm cùng lúc. |

---

## 2. MÔ TẢ TỔNG QUAN (OVERALL DESCRIPTION)

### 2.1. Tác nhân hệ thống (User Classes and Characteristics)

| Mã Tác nhân | Tên Vai trò (Trong DB `ROLES`) | Đặc điểm & Quyền hạn truy cập |
| :--- | :--- | :--- |
| **ACT-01** | **Khách vãng lai (Guest)** | Người dùng chưa đăng nhập; chỉ có quyền truy cập trang Đăng nhập (`/login`) và Đăng ký tài khoản công dân (`/register`). |
| **ACT-02** | **Công dân (`ROLE_USER`)** | Chủ phương tiện đã xác thực; chỉ được xem, khai báo, chỉnh sửa và bấm biển cho các hồ sơ có `ownerId` trùng với `userId` của mình. |
| **ACT-03** | **Cán bộ CSGT (`ROLE_OFFICER`)** | Cán bộ thẩm định; chỉ được phép xem, phê duyệt hoặc từ chối các hồ sơ đăng ký thuộc cùng địa bàn `districtId` với tài khoản cán bộ. |
| **ACT-04** | **Quản trị viên (`ROLE_ADMIN`)** | Quản trị toàn quyền hệ thống; khởi tạo kho biển số, khóa biển số đẹp (`BLOCKED`), quản lý tài khoản Cán bộ và danh mục hệ thống. |

### 2.2. Môi trường vận hành và Ràng buộc kỹ thuật (Operating Environment & Constraints)
* **Ngôn ngữ & Nền tảng:** Java JDK 11 / 17, Jakarta EE / Java EE (Servlet 4.0/5.0, JSP, JSTL 1.2/2.0).
* **Web Container:** Apache Tomcat 9.x hoặc 10.x.
* **Hệ quản trị Cơ sở dữ liệu:** Microsoft SQL Server (kết nối qua thư viện `mssql-jdbc` thuần `PreparedStatement`, không sử dụng ORM như Hibernate/JPA).
* **Giao diện người dùng (Frontend):** HTML5, CSS3, Bootstrap 5, JavaScript (Fetch API / AJAX cho màn hình quay số).

---

## 3. ĐẶC TẢ YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)

### 3.1. Phân hệ Xác thực & Định danh (`UC-AUTH`)

#### FR-01: Đăng ký tài khoản Công dân
* **Tác nhân:** Khách vãng lai (`Guest`).
* **Đầu vào (Inputs):** `userName`, `userpassword`, `fullName`, `identityCard` (12 chữ số), `phone`, `email`, `address`, và chọn `districtId` từ danh sách Quận/Huyện (`DISTRICTS`).
* **Quy trình xử lý:**
  1. Kiểm tra định dạng: `identityCard` phải đúng 12 chữ số; `phone` từ 10-11 chữ số.
  2. Kiểm tra trùng lặp: Truy vấn bảng `USERS` đảm bảo `userName` và `identityCard` chưa tồn tại.
  3. Mặc định gán `roleId = 3` (`ROLE_USER`) và lưu bản ghi mới vào bảng `USERS`.
* **Đầu ra (Outputs):** Thông báo đăng ký thành công và chuyển hướng về trang `/login`.

#### FR-02: Đăng nhập và Phân luồng theo Vai trò
* **Tác nhân:** Tất cả người dùng.
* **Đầu vào:** `userName`, `userpassword`.
* **Quy trình xử lý:**
  1. Đối chiếu thông tin đăng nhập với bảng `USERS` (kết hợp `JOIN` bảng `ROLES` và `DISTRICTS`).
  2. Nếu hợp lệ, khởi tạo `HttpSession` lưu đối tượng `currentUser` và điều hướng theo `roleName`:
     * `ROLE_USER` $\rightarrow$ `/user/dashboard`
     * `ROLE_OFFICER` $\rightarrow$ `/officer/registrations`
     * `ROLE_ADMIN` $\rightarrow$ `/admin/license-plates`

---

### 3.2. Phân hệ Công dân: Khai báo & Bấm biển (`UC-USER`)

#### FR-03: Khai báo phương tiện và Nộp hồ sơ đăng ký mới
* **Tác nhân:** Công dân (`ROLE_USER`).
* **Điều kiện tiên quyết:** Đã đăng nhập với vai trò `ROLE_USER`.
* **Đầu vào:** `brandId`, `typeId`, `modelName`, `engineNumber`, `chassisNumber`, `color`, `engineCapacity`, `vehicleValue`, `taxReceiptNumber`, `invoiceNumber`.
* **Quy trình xử lý (Trong 1 JDBC Transaction):**
  1. Kiểm tra `engineNumber` (Số máy) và `chassisNumber` (Số khung) chưa tồn tại trong bảng `VEHICLES`.
  2. Thực hiện `INSERT` vào bảng `VEHICLES` (với `ownerId = sessionUser.getUserId()`) và lấy khóa chính vừa sinh (`RETURN_GENERATED_KEYS` $\rightarrow$ `vehicleId`).
  3. Thực hiện `INSERT` vào bảng `REGISTRATIONS` với:
     * `vehicleId`: Khóa vừa sinh ở bước 2.
     * `ownerId`: `sessionUser.getUserId()`.
     * `districtId`: `sessionUser.getDistrictId()` (biển số được cấp theo Quận thường trú của chủ xe).
     * `status`: `'PENDING'`.
* **Đầu ra:** Hồ sơ mới xuất hiện trên Dashboard của công dân với trạng thái `PENDING`.

#### FR-04: Chỉnh sửa và Nộp lại hồ sơ bị từ chối (`Resubmit Rejected Registration`)
* **Tác nhân:** Công dân (`ROLE_USER`).
* **Điều kiện tiên quyết:** Hồ sơ có `ownerId` thuộc về công dân đang đăng nhập và có `status = 'REJECTED'`.
* **Quy trình xử lý:**
  1. Hiển thị form chứa dữ liệu hiện tại của `VEHICLES` kèm lý do từ chối (`rejectionReason`).
  2. Khi công dân nhấn lưu: Hệ thống **không tạo bản ghi mới** mà thực hiện `UPDATE` bảng `VEHICLES` và `UPDATE` bảng `REGISTRATIONS` (đặt lại `status = 'PENDING'`, `rejectionReason = NULL`, `submittedAt = GETDATE()`).

#### FR-05: Bấm biển số ngẫu nhiên trực tuyến (`Atomic Random Plate Draw`)
* **Tác nhân:** Công dân (`ROLE_USER`).
* **Điều kiện tiên quyết:** Hồ sơ đang ở trạng thái `status = 'APPROVED'` và `plateId IS NULL`.
* **Đầu vào:** `registrationId` và mã xác thực `drawCode` do người dùng nhập trên giao diện.
* **Quy trình xử lý (Thực thi trong khối đồng bộ & JDBC Transaction):**
  1. Xác thực `registrationId` thuộc về `ownerId` đang đăng nhập, `status = 'APPROVED'` và chuỗi `drawCode` nhập vào khớp chính xác với cột `drawCode` trong bảng `REGISTRATIONS`.
  2. Truy vấn chọn ngẫu nhiên 01 biển số khả dụng thuộc đúng Quận của hồ sơ kèm khóa dòng chống tranh chấp:
     ```sql
     SELECT TOP 1 plateId, plateNumber, fullPlate 
     FROM LICENSE_PLATES WITH (UPDLOCK, READPAST, ROWLOCK)
     WHERE districtId = ? AND status = N'AVAILABLE'
     ORDER BY NEWID();
     ```
  3. Nếu không tìm thấy bản ghi nào $\rightarrow$ `Rollback` và trả về thông báo: *"Kho biển số của Quận hiện tại đã hết, vui lòng liên hệ cơ quan đăng ký!"*.
  4. Nếu tìm thấy biển số:
     * `UPDATE LICENSE_PLATES`: Đặt `status = 'ASSIGNED'`, `assignedAt = GETDATE()` tại `plateId` vừa rút.
     * `UPDATE REGISTRATIONS`: Đặt `plateId = ?`, `status = 'DRAWN'`, `drawnAt = GETDATE()` tại `registrationId`.
  5. Thực hiện `conn.commit()`.
* **Đầu ra:** Trả về phản hồi JSON chứa `fullPlate` (VD: `"29-P1 688.88"`) để giao diện JSP/JavaScript chạy hiệu ứng quay 5 chữ số trong 2.5 giây rồi hiển thị kết quả cuối cùng.

---

### 3.3. Phân hệ Cán bộ CSGT: Thẩm định hồ sơ (`UC-OFFICER`)

#### FR-06: Tra cứu và Lọc danh sách hồ sơ theo Địa bàn
* **Tác nhân:** Cán bộ CSGT (`ROLE_OFFICER`).
* **Quy trình xử lý:**
  * Hệ thống tự động lấy `districtId` của cán bộ đang đăng nhập để lọc bảng `REGISTRATIONS` (`WHERE r.districtId = ?`).
  * Hỗ trợ lọc theo trạng thái: `PENDING` (mặc định), `APPROVED`, `DRAWN`, `REJECTED` và tìm kiếm theo CCCD/Số khung.

#### FR-07: Phê duyệt hồ sơ và Sinh mã bấm biển (`Approve & Generate Draw Code`)
* **Tác nhân:** Cán bộ CSGT (`ROLE_OFFICER`).
* **Điều kiện tiên quyết:** Hồ sơ thuộc cùng `districtId` với cán bộ và đang có `status = 'PENDING'`.
* **Đầu vào:** `registrationId`, `feeAmount` (Mức lệ phí cấp biển, kiểu `DECIMAL(10,2)`).
* **Quy trình xử lý:**
  1. Hệ thống tự động sinh một mã `drawCode` duy nhất theo định dạng `DRAW-XXXXXX` (6 chữ số ngẫu nhiên, kiểm tra không trùng trong DB).
  2. Cập nhật bảng `REGISTRATIONS`:
     * `status = 'APPROVED'`
     * `officerId = sessionOfficer.getUserId()`
     * `feeAmount = ?`
     * `drawCode = ?`
     * `approvedAt = GETDATE()`
     * `rejectionReason = NULL`

#### FR-08: Từ chối hồ sơ đăng ký (`Reject Registration`)
* **Tác nhân:** Cán bộ CSGT (`ROLE_OFFICER`).
* **Điều kiện tiên quyết:** Hồ sơ đang có `status = 'PENDING'`.
* **Đầu vào:** `registrationId`, `rejectionReason` (Bắt buộc nhập, tối đa 225 ký tự).
* **Quy trình xử lý:** Cập nhật bảng `REGISTRATIONS` với `status = 'REJECTED'`, `officerId = sessionOfficer.getUserId()`, `rejectionReason = ?`.

---

### 3.4. Phân hệ Quản trị viên: Quản lý Kho biển & Danh mục (`UC-ADMIN`)

#### FR-09: Sinh kho biển số tự động theo dải (`Batch Plate Generation`)
* **Tác nhân:** Quản trị viên (`ROLE_ADMIN`).
* **Đầu vào:** Chọn `districtId` (từ bảng `DISTRICTS`), nhập `startNumber` (VD: `10000`), `endNumber` (VD: `10199`), tùy chọn tự động khóa biển đẹp.
* **Quy trình xử lý:**
  1. Lấy `platePrefix` của Quận đã chọn (VD: `29-P1`).
  2. Duyệt vòng lặp từ `startNumber` đến `endNumber`, định dạng 5 chữ số thành `XXX.XX` (VD: `10000` $\rightarrow$ `100.00`) và ghép thành `fullPlate` (`29-P1 100.00`).
  3. Nếu bật tùy chọn lọc biển đẹp (Ngũ quý như `555.55`, `999.99` hoặc Sảnh tiến `123.45`), gán trạng thái ban đầu là `'BLOCKED'`, ngược lại gán `'AVAILABLE'`.
  4. Sử dụng `PreparedStatement.addBatch()` và `executeBatch()` để chèn hàng loạt vào bảng `LICENSE_PLATES` (bỏ qua các biển đã tồn tại).

#### FR-10: Khóa / Mở khóa biển số (`Block / Unblock Plate`)
* **Tác nhân:** Quản trị viên (`ROLE_ADMIN`).
* **Quy trình xử lý:** Cho phép chuyển đổi trạng thái của một biển số trong bảng `LICENSE_PLATES` giữa `'AVAILABLE'` và `'BLOCKED'`. Hệ thống **nghiêm cấm** thay đổi trạng thái của biển số đã có `status = 'ASSIGNED'`.

---

## 4. MA TRẬN QUY TẮC NGHIỆP VỤ (BUSINESS RULES)

Các quy tắc này phải được kiểm tra nghiêm ngặt ở tầng `Service` / `Servlet` trước khi gọi xuống `DAO`:

| Mã Quy tắc | Tên Quy tắc | Mô tả logic bắt buộc |
| :--- | :--- | :--- |
| **BR-01** | **Khóa vùng địa lý (District Isolation)** | Công dân thuộc `districtId` nào chỉ được bốc biển số trong kho `LICENSE_PLATES` của `districtId` đó. Cán bộ thuộc `districtId` nào chỉ được duyệt hồ sơ của `districtId` đó. |
| **BR-02** | **Tính duy nhất của Phương tiện** | Mỗi `engineNumber`, `chassisNumber` trong bảng `VEHICLES` là duy nhất trên toàn hệ thống. Một `vehicleId` chỉ xuất hiện tối đa 1 lần trong bảng `REGISTRATIONS`. |
| **BR-03** | **Trình tự Trạng thái Hồ sơ (State Transition)** | Hồ sơ chỉ được phép chuyển trạng thái theo đúng chiều: <br>• `PENDING` $\rightarrow$ `APPROVED` (Bởi Officer)<br>• `PENDING` $\rightarrow$ `REJECTED` (Bởi Officer)<br>• `REJECTED` $\rightarrow$ `PENDING` (Bởi User khi sửa hồ sơ)<br>• `APPROVED` $\rightarrow$ `DRAWN` (Bởi User khi bấm biển).<br>Mọi thao tác nhảy cóc (VD: từ `PENDING` sang `DRAWN`) đều bị từ chối. |
| **BR-04** | **Tính bất biến sau khi Bấm biển** | Khi hồ sơ đã đạt trạng thái `DRAWN` và biển số đạt trạng thái `ASSIGNED`, dữ liệu không thể bị thu hồi, xóa hoặc bấm lại dưới mọi hình thức. |
| **BR-05** | **Tính hợp lệ của Giá trị và Dung tích** | `engineCapacity >= 0` (bằng 0 đối với xe máy điện), `vehicleValue > 0`, và `feeAmount > 0` khi phê duyệt. |

---

## 5. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)

1. **NFR-01 (An toàn đồng thời - Concurrency & Atomicity):**
   * Khi có nhiều yêu cầu bấm biển (`FR-05`) gửi lên đồng thời trong cùng một Quận, hệ thống phải kết hợp khóa đồng bộ mức ứng dụng (`synchronized` theo `districtId`) và mức cô lập giao dịch JDBC (`conn.setAutoCommit(false)` cùng gợi ý khóa `WITH (UPDLOCK, READPAST, ROWLOCK)`) để đảm bảo 100% không xảy ra lỗi cấp trùng 1 biển số cho 2 hồ sơ.
2. **NFR-02 (Bảo mật - Security):**
   * Toàn bộ các trang `.jsp` phải được đặt bên trong thư mục `/WEB-INF/views/` để ngăn người dùng gõ trực tiếp đường dẫn file `.jsp` trên trình duyệt.
   * Sử dụng `Servlet Filter` (`AuthFilter`) để kiểm tra `HttpSession` và chặn truy cập trái phép giữa các đường dẫn `/user/*`, `/officer/*`, `/admin/*`.
   * Mọi câu lệnh truy vấn JDBC bắt buộc dùng `PreparedStatement` để chống tấn công SQL Injection.
3. **NFR-03 (Hiệu năng & Trải nghiệm người dùng - Usability):**
   * Thao tác bấm biển số thực hiện qua `Fetch API` (AJAX) không làm tải lại (reload) toàn bộ trang JSP.
   * Thời gian phản hồi của API bấm biển ở phía Server dưới **500ms** nhờ đánh chỉ mục `idx_district_status` trên bảng `LICENSE_PLATES`.

---

## 6. MA TRẬN PHÂN QUYỀN TRUY CẬP (URL & ROLE MATRIX)

Bảng dưới đây làm căn cứ trực tiếp để lập trình lớp `AuthFilter.java`:

| Đường dẫn URL (Servlet Pattern) | Phương thức | `Guest` | `ROLE_USER` | `ROLE_OFFICER` | `ROLE_ADMIN` |
| :--- | :--- | :---: | :---: | :---: | :---: |
| `/login`, `/register`, `/logout` | `GET`, `POST` | Cho phép | Cho phép | Cho phép | Cho phép |
| `/user/dashboard` | `GET` | Chặn ($\rightarrow$ `/login`) | **Cho phép** | Chặn (403) | Chặn (403) |
| `/user/vehicle-form` | `GET`, `POST` | Chặn ($\rightarrow$ `/login`) | **Cho phép** | Chặn (403) | Chặn (403) |
| `/user/draw-plate` | `GET`, `POST` | Chặn ($\rightarrow$ `/login`) | **Cho phép** | Chặn (403) | Chặn (403) |
| `/officer/registrations` | `GET` | Chặn ($\rightarrow$ `/login`) | Chặn (403) | **Cho phép** | Cho phép |
| `/officer/review` | `POST` | Chặn ($\rightarrow$ `/login`) | Chặn (403) | **Cho phép** | Chặn (403) |
| `/admin/license-plates` | `GET`, `POST` | Chặn ($\rightarrow$ `/login`) | Chặn (403) | Chặn (403) | **Cho phép** |
| `/admin/users` | `GET`, `POST` | Chặn ($\rightarrow$ `/login`) | Chặn (403) | Chặn (403) | **Cho phép** |

---

## 7. CẤU TRÚC CƠ SỞ DỮ LIỆU & RÀNG BUỘC (DATABASE MAPPING)

Hệ thống bao gồm 8 bảng dữ liệu quan hệ trong SQL Server (`DangKyXeVaBamBienProject`):

1. **`ROLES`**: Lưu danh mục 3 vai trò (`ROLE_ADMIN`, `ROLE_OFFICER`, `ROLE_USER`).
2. **`DISTRICTS`**: Lưu danh mục Tỉnh/Thành phố, Quận/Huyện và Mã đầu biển (`platePrefix` - Unique).
3. **`USERS`**: Lưu thông tin tài khoản, CCCD (`identityCard` - Unique), liên kết tới `DISTRICTS` và `ROLES`.
4. **`VEHICLE_BRANDS`**: Lưu danh mục hãng sản xuất xe (Honda, Yamaha, VinFast...).
5. **`VEHICLE_TYPES`**: Lưu phân loại xe máy và khoảng dung tích xi-lanh.
6. **`VEHICLES`**: Lưu thông tin chi tiết phương tiện, Số máy (`engineNumber` - Unique), Số khung (`chassisNumber` - Unique), Biên lai thuế và Hóa đơn.
7. **`LICENSE_PLATES`**: Lưu kho biển số theo từng Quận (`districtId`), trạng thái (`AVAILABLE`, `ASSIGNED`, `BLOCKED`) và thời điểm cấp (`assignedAt`).
8. **`REGISTRATIONS`**: Lưu hồ sơ đăng ký kết nối giữa `VEHICLES`, `USERS` (chủ xe & cán bộ duyệt), `DISTRICTS` và `LICENSE_PLATES`, cùng mã bấm biển (`drawCode` - Unique) và trạng thái (`PENDING`, `APPROVED`, `DRAWN`, `REJECTED`).