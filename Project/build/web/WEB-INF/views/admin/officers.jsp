<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Nhân Sự Cán Bộ CSGT Quận/Huyện (ROLE_ADMIN - Chuẩn VNeID)</title>
    
    <!-- Google Fonts: Be Vietnam Pro & Montserrat -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&family=Montserrat:wght@600;700;800;900&display=swap" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --vneid-red: #a81c1e;
            --vneid-red-dark: #7a1214;
            --vneid-gold: #e5a919;
            --vneid-gold-light: #fbe083;
            --text-dark: #1e293b;
            --bg-light: #f1f5f9;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Be Vietnam Pro', sans-serif;
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Top Admin Navbar */
        .navbar-admin {
            background: linear-gradient(135deg, #180304 0%, #3e070a 45%, #7a1214 100%);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
            border-bottom: 2px solid var(--vneid-gold);
            padding: 12px 0;
        }

        .brand-emblem {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: radial-gradient(circle, #fff3c4 0%, #e5a919 70%, #996500 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--vneid-red);
            font-size: 22px;
            border: 2px solid #fffae6;
            box-shadow: 0 0 10px rgba(229, 169, 25, 0.5);
        }

        .admin-badge-nav {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(251, 224, 131, 0.4);
            border-radius: 30px;
            padding: 5px 14px;
            color: #ffffff;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Card Thống Kê Nhân Sự */
        .stat-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            position: relative;
            overflow: hidden;
            height: 100%;
        }

        .stat-card::before {
            content: "";
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 5px;
        }

        .border-kpi-total::before { background-color: var(--vneid-red); }
        .border-kpi-assigned::before { background-color: #16a34a; }
        .border-kpi-unassigned::before { background-color: #eab308; }

        .stat-count {
            font-size: 1.85rem;
            font-weight: 800;
            font-family: 'Montserrat', sans-serif;
            line-height: 1.1;
        }

        /* Khối Card Section */
        .content-card {
            background: #ffffff;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 24px;
        }

        .content-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 14px;
            border-bottom: 1.5px solid #f1f5f9;
        }

        .content-card-title {
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--vneid-red-dark);
            display: flex;
            align-items: center;
            gap: 10px;
            margin: 0;
        }

        /* Bảng Danh Sách */
        .table-custom {
            margin-bottom: 0;
        }

        .table-custom thead th {
            background-color: #f8fafc;
            color: #475569;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #e2e8f0;
            padding: 12px 14px;
            vertical-align: middle;
        }

        .table-custom tbody td {
            padding: 14px;
            vertical-align: middle;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.88rem;
        }

        .table-custom tbody tr:hover {
            background-color: #f8fafc;
        }

        /* Badge Địa Bàn CSGT */
        .district-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(168, 28, 30, 0.08);
            color: var(--vneid-red);
            border: 1px solid rgba(168, 28, 30, 0.2);
            padding: 5px 10px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.82rem;
        }

        .plate-prefix-tag {
            background: #e2e8f0;
            color: #1e293b;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-family: monospace;
            font-weight: bold;
        }

        /* Nút Submit Gradient */
        .btn-vneid-primary {
            background: linear-gradient(135deg, #c92a2a 0%, #a81c1e 100%);
            border: none;
            color: #ffffff;
            font-weight: 700;
            border-radius: 8px;
            padding: 10px 18px;
            transition: all 0.2s ease;
        }

        .btn-vneid-primary:hover {
            background: linear-gradient(135deg, #d93838 0%, #ba1b1d 100%);
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(168, 28, 30, 0.3);
        }

        /* Footer */
        .footer-admin {
            margin-top: auto;
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
            padding: 16px 0;
            font-size: 0.82rem;
            color: #64748b;
        }
    </style>
</head>
<body>

    <!-- KIỂM TRA BẢO MẬT: BẮT BUỘC ROLE_ADMIN -->
    <c:if test="${empty sessionScope.currentUser || sessionScope.currentUser.role.roleName ne 'ROLE_ADMIN'}">
        <c:redirect url="/login" />
    </c:if>

    <!-- TOP NAVBAR QUẢN TRỊ TRUNG ƯƠNG -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-admin">
        <div class="container-fluid px-lg-4">
            <a class="navbar-brand d-flex align-items-center gap-3 text-white fw-bold text-decoration-none" href="${pageContext.request.contextPath}/admin/home">
                <div class="brand-emblem">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <div style="font-size: 1.15rem; text-transform: uppercase; letter-spacing: 0.5px;">Cổng Quản Trị Hệ Thống Trung Ương</div>
                    <div style="font-size: 0.72rem; color: var(--vneid-gold-light); font-weight: 500;">
                        Cục Cảnh Sát Giao Thông &bull; Bộ Công An &bull; Quản Trị Nhân Sự Cán Bộ CSGT
                    </div>
                </div>
            </a>

            <div class="d-flex align-items-center gap-2">
                <div class="admin-badge-nav d-none d-md-flex">
                    <i class="fa-solid fa-user-gear fs-5 text-warning"></i>
                    <div>
                        <div class="fw-bold"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                        <div style="font-size: 0.72rem; color: rgba(255,255,255,0.85);">
                            Quản trị viên tối cao &bull; CCCD: <c:out value="${sessionScope.currentUser.identityCard}" />
                        </div>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/admin/home" class="btn btn-outline-warning btn-sm rounded-pill px-3 text-warning border-warning">
                    <i class="fa-solid fa-database me-1"></i> Quản Lý Kho Biển Số
                </a>

                <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-house me-1"></i> Cổng Dịch Vụ Công
                </a>

                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-right-from-bracket me-1"></i> Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <!-- NỘI DUNG CHÍNH -->
    <main class="container-fluid px-lg-4 my-4">

        <!-- THÔNG BÁO FLASH MESSAGE TỪ SESSION -->
        <c:if test="${not empty flashSuccessMessage}">
            <div class="alert alert-success border-0 shadow-sm d-flex align-items-center gap-2 mb-3">
                <i class="fa-solid fa-circle-check fs-5 text-success"></i>
                <div class="fw-medium"><c:out value="${flashSuccessMessage}" /></div>
            </div>
        </c:if>

        <c:if test="${not empty flashErrorMessage}">
            <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center gap-2 mb-3">
                <i class="fa-solid fa-triangle-exclamation fs-5 text-danger"></i>
                <div class="fw-medium"><c:out value="${flashErrorMessage}" /></div>
            </div>
        </c:if>

        <!-- HÀNG 1: THỐNG KÊ NHÂN SỰ CÁN BỘ CSGT -->
        <div class="row g-3 mb-4">
            
            <!-- Tổng số cán bộ -->
            <div class="col-md-4 col-sm-6">
                <div class="stat-card border-kpi-total">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted small fw-bold text-uppercase">Tổng Số Cán Bộ CSGT</span>
                        <span class="badge bg-danger"><i class="fa-solid fa-user-shield"></i> ROLE_OFFICER</span>
                    </div>
                    <div class="stat-count text-danger mt-2">
                        <fmt:formatNumber value="${not empty totalOfficers ? totalOfficers : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Lực lượng thẩm định hồ sơ toàn hệ thống</div>
                </div>
            </div>

            <!-- Quận/Huyện đã có Cán bộ -->
            <div class="col-md-4 col-sm-6">
                <div class="stat-card border-kpi-assigned">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-success small fw-bold text-uppercase">Quận/Huyện Đã Có Cán Bộ</span>
                        <span class="badge bg-success"><i class="fa-solid fa-check-double"></i> Đang hoạt động</span>
                    </div>
                    <div class="stat-count text-success mt-2">
                        <fmt:formatNumber value="${not empty assignedDistricts ? assignedDistricts : 0}" type="number" /> 
                        <span class="fs-6 text-muted">/ <fmt:formatNumber value="${not empty totalDistricts ? totalDistricts : 0}" type="number" /> Quận</span>
                    </div>
                    <div class="text-muted small mt-1">Đã có người tiếp quản hồ sơ xe máy</div>
                </div>
            </div>

            <!-- Quận/Huyện chưa có Cán bộ (Cần bổ nhiệm) -->
            <div class="col-md-4 col-sm-12">
                <div class="stat-card border-kpi-unassigned">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-warning text-dark small fw-bold text-uppercase">Quận Còn Trống Cán Bộ</span>
                        <span class="badge ${unassignedDistricts > 0 ? 'bg-warning text-dark' : 'bg-secondary'}">
                            <i class="fa-solid fa-triangle-exclamation"></i> Cần bổ nhiệm
                        </span>
                    </div>
                    <div class="stat-count text-warning text-dark mt-2">
                        <fmt:formatNumber value="${not empty unassignedDistricts ? unassignedDistricts : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Hồ sơ người dân tại đây sẽ chờ CSGT duyệt</div>
                </div>
            </div>

        </div>

        <div class="row g-4">
            
            <!-- CỘT TRÁI: FORM CẤP MỚI TÀI KHOẢN CÁN BỘ CSGT -->
            <div class="col-lg-4">
                <div class="content-card">
                    <div class="content-card-header">
                        <h5 class="content-card-title">
                            <i class="fa-solid fa-user-plus text-danger"></i> Cấp Tài Khoản Cán Bộ Mới
                        </h5>
                    </div>

                    <form action="${pageContext.request.contextPath}/admin/officers" method="POST">
                        <input type="hidden" name="action" value="create">

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Quận/Huyện Phân Công Công Tác <span class="text-danger">*</span></label>
                            <select name="districtId" class="form-select form-select-sm" required>
                                <option value="">-- Chọn Quận/Huyện phụ trách --</option>
                                <c:forEach items="${districtList}" var="d">
                                    <c:set var="officerCount" value="${officerCountMap[d.districtId]}" />
                                    <option value="${d.districtId}">
                                        <c:out value="${d.districtName}" /> (${d.platePrefix}) 
                                        <c:choose>
                                            <c:when test="${empty officerCount || officerCount == 0}">
                                                🔴 [Chưa có CSGT]
                                            </c:when>
                                            <c:otherwise>
                                                🟢 [Đã có ${officerCount} CSGT]
                                            </c:otherwise>
                                        </c:choose>
                                    </option>
                                </c:forEach>
                            </select>
                            <div class="form-text text-muted small">
                                Cán bộ được tạo sẽ thẩm định hồ sơ thuộc địa bàn Quận này.
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Họ và Tên Cán Bộ <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" class="form-control form-control-sm" placeholder="Ví dụ: ĐẠI ÚY TRẦN VĂN BÌNH" required maxlength="100">
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-sm-6">
                                <label class="form-label small fw-bold text-dark">Số CCCD (12 số) <span class="text-danger">*</span></label>
                                <input type="text" name="identityCard" class="form-control form-control-sm" placeholder="001202000099" pattern="[0-9]{12}" title="Đúng 12 chữ số" required maxlength="12">
                            </div>
                            <div class="col-sm-6">
                                <label class="form-label small fw-bold text-dark">Số Điện Thoại <span class="text-danger">*</span></label>
                                <input type="tel" name="phone" class="form-control form-control-sm" placeholder="0988776655" pattern="[0-9]{10,11}" title="Từ 10 đến 11 số" required maxlength="11">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Địa Chỉ Công Tác / Trụ Sở <span class="text-danger">*</span></label>
                            <input type="text" name="address" class="form-control form-control-sm" placeholder="Đội CSGT - Công an Quận..." required maxlength="255">
                        </div>

                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Địa Chỉ Email</label>
                            <input type="email" name="email" class="form-control form-control-sm" placeholder="csgt.quan@bocongan.gov.vn" maxlength="100">
                        </div>

                        <div class="row g-2 mb-4">
                            <div class="col-sm-6">
                                <label class="form-label small fw-bold text-dark">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                <input type="text" name="userName" class="form-control form-control-sm" placeholder="officer_badinh" required maxlength="50" autocomplete="off">
                            </div>
                            <div class="col-sm-6">
                                <label class="form-label small fw-bold text-dark">Mật Khẩu Ban Đầu <span class="text-danger">*</span></label>
                                <input type="password" name="userpassword" class="form-control form-control-sm" placeholder="Tối thiểu 6 ký tự" minlength="6" required autocomplete="new-password">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-vneid-primary w-100">
                            <i class="fa-solid fa-shield-halved me-1"></i> BỔ NHIỆM & CẤP TÀI KHOẢN CSGT
                        </button>
                    </form>
                </div>
            </div>

            <!-- CỘT PHẢI: BẢNG DANH SÁCH CÁN BỘ CSGT & ĐIỀU CHUYỂN -->
            <div class="col-lg-8">
                <div class="content-card">
                    <div class="content-card-header flex-wrap gap-2">
                        <h5 class="content-card-title">
                            <i class="fa-solid fa-users-gear text-danger"></i> Danh Sách Cán Bộ CSGT Đang Phụ Trách
                        </h5>
                        <span class="badge bg-dark"><c:out value="${officersList.size()}" /> Cán bộ</span>
                    </div>

                    <!-- BỘ LỌC VÀ TÌM KIẾM THUẦN HTTP GET (ZERO JS) -->
                    <form action="${pageContext.request.contextPath}/admin/officers" method="GET" class="row g-2 mb-3 pb-3 border-bottom">
                        <div class="col-md-5">
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                <input type="text" name="keyword" class="form-control" placeholder="Tìm theo Tên, CCCD, Username, SĐT..." value="<c:out value="${keyword}" />">
                            </div>
                        </div>

                        <div class="col-md-5">
                            <select name="districtId" class="form-select form-select-sm">
                                <option value="">-- Tất cả Quận/Huyện --</option>
                                <c:forEach items="${districtList}" var="d">
                                    <option value="${d.districtId}" ${d.districtId == selectedDistrictId ? 'selected' : ''}>
                                        <c:out value="${d.districtName}" /> (<c:out value="${d.platePrefix}" />)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-2 d-flex gap-1">
                            <button type="submit" class="btn btn-dark btn-sm flex-grow-1">
                                <i class="fa-solid fa-filter me-1"></i> Lọc
                            </button>
                            <c:if test="${not empty keyword || not empty selectedDistrictId}">
                                <a href="${pageContext.request.contextPath}/admin/officers" class="btn btn-outline-secondary btn-sm" title="Xóa bộ lọc">
                                    <i class="fa-solid fa-xmark"></i>
                                </a>
                            </c:if>
                        </div>
                    </form>

                    <!-- BẢNG CÁN BỘ -->
                    <div class="table-responsive">
                        <table class="table table-custom">
                            <thead>
                                <tr>
                                    <th>Cán Bộ Thẩm Định</th>
                                    <th>Định Danh & Liên Hệ</th>
                                    <th>Quận Phụ Trách</th>
                                    <th style="min-width: 220px;">Điều Chuyển Quận</th>
                                    <th style="min-width: 170px;">Đặt Lại MK</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty officersList}">
                                        <c:forEach items="${officersList}" var="o">
                                            <tr>
                                                <!-- Cột 1: Thông tin cán bộ -->
                                                <td>
                                                    <div class="fw-bold text-dark"><c:out value="${o.fullName}" /></div>
                                                    <div class="text-muted small">
                                                        <i class="fa-regular fa-user me-1"></i><c:out value="${o.userName}" />
                                                    </div>
                                                </td>

                                                <!-- Cột 2: CCCD & SĐT -->
                                                <td>
                                                    <div class="fw-bold text-primary small">
                                                        <i class="fa-solid fa-id-card me-1"></i><c:out value="${o.identityCard}" />
                                                    </div>
                                                    <div class="text-muted small">
                                                        <i class="fa-solid fa-phone me-1"></i><c:out value="${o.phone}" />
                                                    </div>
                                                    <c:if test="${not empty o.email}">
                                                        <div class="text-muted small" style="font-size: 0.75rem;">
                                                            <i class="fa-regular fa-envelope me-1"></i><c:out value="${o.email}" />
                                                        </div>
                                                    </c:if>
                                                </td>

                                                <!-- Cột 3: Quận phụ trách -->
                                                <td>
                                                    <div class="district-badge">
                                                        <i class="fa-solid fa-location-dot"></i>
                                                        <c:out value="${o.district.districtName}" />
                                                    </div>
                                                    <div class="mt-1">
                                                        <span class="plate-prefix-tag"><c:out value="${o.district.platePrefix}" /></span>
                                                    </div>
                                                </td>

                                                <!-- Cột 4: Form Điều Chuyển Địa Bàn (Thuần POST) -->
                                                <td>
                                                    <form action="${pageContext.request.contextPath}/admin/officers" method="POST" class="d-flex gap-1">
                                                        <input type="hidden" name="action" value="updateDistrict">
                                                        <input type="hidden" name="officerUserId" value="${o.userId}">
                                                        <select name="newDistrictId" class="form-select form-select-sm" required style="font-size: 0.8rem;">
                                                            <c:forEach items="${districtList}" var="d">
                                                                <option value="${d.districtId}" ${d.districtId == o.districtId ? 'selected' : ''}>
                                                                    <c:out value="${d.districtName}" />
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                        <button type="submit" class="btn btn-outline-primary btn-sm flex-shrink-0" title="Lưu chuyển quận">
                                                            <i class="fa-solid fa-repeat"></i>
                                                        </button>
                                                    </form>
                                                </td>

                                                <!-- Cột 5: Form Đặt Lại Mật Khẩu (Thuần POST) -->
                                                <td>
                                                    <form action="${pageContext.request.contextPath}/admin/officers" method="POST" class="d-flex gap-1">
                                                        <input type="hidden" name="action" value="resetPassword">
                                                        <input type="hidden" name="officerUserId" value="${o.userId}">
                                                        <input type="password" name="newPassword" class="form-control form-control-sm" placeholder="MK mới (>=6)" minlength="6" required style="font-size: 0.8rem;">
                                                        <button type="submit" class="btn btn-outline-warning text-dark btn-sm flex-shrink-0" title="Đặt lại mật khẩu">
                                                            <i class="fa-solid fa-key"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center py-4 text-muted">
                                                <i class="fa-solid fa-user-slash fs-3 d-block mb-2 text-secondary"></i>
                                                Không tìm thấy Cán bộ CSGT nào phù hợp với bộ lọc tìm kiếm.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>

        </div>

    </main>

    <!-- FOOTER HỆ THỐNG -->
    <footer class="footer-admin text-center">
        <div class="container-fluid">
            &copy; 2026 Cục Cảnh Sát Giao Thông &bull; Bộ Công An &bull; Cổng Quản Trị Hệ Thống Đăng Ký & Bấm Biển Số Xe Máy Toàn Quốc.
        </div>
    </footer>

</body>
</html>
