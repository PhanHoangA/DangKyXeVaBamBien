<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Quản Trị Trung Ương - Kho Biển Số & Danh Mục (ROLE_ADMIN - Chuẩn VNeID)</title>
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
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(251, 224, 131, 0.4);
            border-radius: 30px;
            padding: 6px 16px;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.88rem;
        }

        /* Card KPI Thống kê */
        .stat-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 18px 20px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.08);
        }

        .stat-count {
            font-family: 'Montserrat', sans-serif;
            font-size: 1.85rem;
            font-weight: 800;
            line-height: 1.1;
        }

        .border-kpi-total { border-left: 5px solid #0f172a; }
        .border-kpi-avail { border-left: 5px solid #16a34a; }
        .border-kpi-assign { border-left: 5px solid #0284c7; }
        .border-kpi-block { border-left: 5px solid #dc2626; }

        /* Biển số xe mô phỏng */
        .plate-badge-vneid {
            display: inline-block;
            background: #ffffff;
            color: #1e293b;
            border: 2px solid #1e293b;
            border-radius: 6px;
            padding: 4px 10px;
            font-family: 'Montserrat', monospace;
            font-weight: 800;
            font-size: 0.95rem;
            letter-spacing: 1px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .plate-badge-blocked {
            display: inline-block;
            background: #fff1f2;
            color: #be123c;
            border: 2px dashed #e11d48;
            border-radius: 6px;
            padding: 4px 10px;
            font-family: 'Montserrat', monospace;
            font-weight: 800;
            font-size: 0.95rem;
            letter-spacing: 1px;
        }

        .section-header {
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 12px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            color: var(--vneid-red);
        }

        .footer-vneid {
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
            padding: 16px 0;
            margin-top: auto;
            text-align: center;
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
                        Cục Cảnh Sát Giao Thông &bull; Bộ Công An &bull; Quản Trị Kho Biển Số Toàn Quốc
                    </div>
                </div>
            </a>

            <div class="d-flex align-items-center gap-3">
                <div class="admin-badge-nav d-none d-md-flex">
                    <i class="fa-solid fa-user-gear fs-5 text-warning"></i>
                    <div>
                        <div class="fw-bold"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                        <div style="font-size: 0.72rem; color: rgba(255,255,255,0.85);">
                            Quản trị viên tối cao &bull; CCCD: <c:out value="${sessionScope.currentUser.identityCard}" />
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/admin/officers" class="btn btn-warning btn-sm rounded-pill px-3 fw-bold text-dark">
                    <i class="fa-solid fa-user-shield me-1"></i> Quản Lý Cán Bộ CSGT
                </a>
                <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-warning btn-sm rounded-pill px-3 text-warning border-warning">
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

        <!-- THÔNG BÁO FLASH MESSAGE (THUẦN JSTL TỪ SERVLET) -->
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success border-0 shadow-sm d-flex align-items-center gap-2 mb-3">
                <i class="fa-solid fa-circle-check fs-5 text-success"></i>
                <div class="fw-medium"><c:out value="${successMessage}" /></div>
            </div>
        </c:if>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center gap-2 mb-3">
                <i class="fa-solid fa-triangle-exclamation fs-5 text-danger"></i>
                <div class="fw-medium"><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- HÀNG 1: THỐNG KÊ TOÀN CẢNH KHO BIỂN SỐ VÀ HỆ THỐNG -->
        <div class="row g-3 mb-4">
            
            <!-- Tổng kho biển -->
            <div class="col-md-3 col-sm-6">
                <div class="stat-card border-kpi-total">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted small fw-bold text-uppercase">Tổng Biển Số Trong Kho</span>
                        <span class="badge bg-dark"><i class="fa-solid fa-database"></i> Kho số</span>
                    </div>
                    <div class="stat-count text-dark mt-2">
                        <fmt:formatNumber value="${not empty plateStats['TOTAL'] ? plateStats['TOTAL'] : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Toàn bộ biển số đã khởi tạo</div>
                </div>
            </div>

            <!-- Biển khả dụng (AVAILABLE) -->
            <div class="col-md-3 col-sm-6">
                <div class="stat-card border-kpi-avail">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-success small fw-bold text-uppercase">Khả Dụng Bấm Biển</span>
                        <span class="badge bg-success"><i class="fa-solid fa-check"></i> Sẵn sàng</span>
                    </div>
                    <div class="stat-count text-success mt-2">
                        <fmt:formatNumber value="${not empty plateStats['AVAILABLE'] ? plateStats['AVAILABLE'] : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Công dân có thể bốc ngẫu nhiên</div>
                </div>
            </div>

            <!-- Biển đã cấp định danh (ASSIGNED) -->
            <div class="col-md-3 col-sm-6">
                <div class="stat-card border-kpi-assign">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-primary small fw-bold text-uppercase">Đã Cấp Định Danh</span>
                        <span class="badge bg-primary"><i class="fa-solid fa-id-card"></i> Gắn với CCCD</span>
                    </div>
                    <div class="stat-count text-primary mt-2">
                        <fmt:formatNumber value="${not empty plateStats['ASSIGNED'] ? plateStats['ASSIGNED'] : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Đã cấp định danh vĩnh viễn</div>
                </div>
            </div>

            <!-- Biển số đẹp bị khóa / Đấu giá (BLOCKED) -->
            <div class="col-md-3 col-sm-6">
                <div class="stat-card border-kpi-block">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-danger small fw-bold text-uppercase">Biển Đẹp / Đấu Giá</span>
                        <span class="badge bg-danger"><i class="fa-solid fa-gavel"></i> Khóa tự động</span>
                    </div>
                    <div class="stat-count text-danger mt-2">
                        <fmt:formatNumber value="${not empty plateStats['BLOCKED'] ? plateStats['BLOCKED'] : 0}" type="number" />
                    </div>
                    <div class="text-muted small mt-1">Ngũ quý, sảnh tiến giữ lại</div>
                </div>
            </div>

        </div>

        <!-- HÀNG THỐNG KÊ QUY MÔ DỮ LIỆU DÂN CƯ & HỒ SƠ -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-3">
                <div class="row g-3 text-center text-sm-start align-items-center">
                    <div class="col-md-3 col-6 border-end">
                        <div class="text-muted small">Chủ xe (Công dân):</div>
                        <div class="fw-bold fs-5 text-dark"><i class="fa-solid fa-users text-primary me-1"></i> <fmt:formatNumber value="${not empty systemStats['TOTAL_CITIZENS'] ? systemStats['TOTAL_CITIZENS'] : 0}" type="number" /> tài khoản</div>
                    </div>
                    <div class="col-md-3 col-6 border-end">
                        <div class="text-muted small">Cán bộ CSGT địa bàn:</div>
                        <div class="fw-bold fs-5 text-dark"><i class="fa-solid fa-user-shield text-warning me-1"></i> <fmt:formatNumber value="${not empty systemStats['TOTAL_OFFICERS'] ? systemStats['TOTAL_OFFICERS'] : 0}" type="number" /> cán bộ</div>
                    </div>
                    <div class="col-md-3 col-6 border-end">
                        <div class="text-muted small">Xe máy đã khai báo:</div>
                        <div class="fw-bold fs-5 text-dark"><i class="fa-solid fa-motorcycle text-success me-1"></i> <fmt:formatNumber value="${not empty systemStats['TOTAL_VEHICLES'] ? systemStats['TOTAL_VEHICLES'] : 0}" type="number" /> phương tiện</div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="text-muted small">Hồ sơ thẩm định toàn quốc:</div>
                        <div class="fw-bold fs-5 text-danger"><i class="fa-solid fa-folder-tree me-1"></i> <fmt:formatNumber value="${not empty systemStats['TOTAL_REGISTRATIONS'] ? systemStats['TOTAL_REGISTRATIONS'] : 0}" type="number" /> hồ sơ</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            
            <!-- CỘT TRÁI: CÔNG CỤ SINH KHO BIỂN SỐ HÀNG LOẠT (FR-09) -->
            <div class="col-xl-4 col-lg-5">
                <div class="card border-0 shadow-sm h-100 p-4">
                    <div class="section-header">
                        <i class="fa-solid fa-gears fs-5"></i>
                        <span>Khởi Tạo Kho Biển Số Hàng Loạt</span>
                    </div>

                    <p class="text-muted small mb-3">
                        Hệ thống tự động ghép Mã đầu biển của Quận (`platePrefix`) với dải 5 chữ số định dạng `XXX.XX`, sử dụng xử lý lô (`executeBatch`) tốc độ cao.
                    </p>

                    <!-- FORM SINH BIỂN SỐ (FORM POST THUẦN TÚY KHÔNG JS) -->
                    <form action="${pageContext.request.contextPath}/admin/home" method="POST">
                        <input type="hidden" name="action" value="batch_generate">

                        <!-- Chọn Quận/Huyện -->
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-dark">Địa bàn cấp biển (Quận / Huyện):</label>
                            <select name="districtId" class="form-select" required>
                                <option value="">-- Chọn Quận/Huyện --</option>
                                <c:forEach var="d" items="${districts}">
                                    <option value="${d.districtId}">
                                        <c:out value="${d.provinceName}" /> &bull; <c:out value="${d.districtName}" /> (Đầu biển: ${d.platePrefix})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Dải số bắt đầu & kết thúc -->
                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label small fw-bold text-dark">Số bắt đầu:</label>
                                <input type="number" 
                                       name="startNumber" 
                                       class="form-control font-monospace fw-bold" 
                                       placeholder="VD: 10000" 
                                       value="10000" 
                                       min="0" 
                                       max="99999" 
                                       required>
                                <div class="form-text small" style="font-size: 0.72rem;">Ghép thành: <code>100.00</code></div>
                            </div>
                            <div class="col-6">
                                <label class="form-label small fw-bold text-dark">Số kết thúc:</label>
                                <input type="number" 
                                       name="endNumber" 
                                       class="form-control font-monospace fw-bold" 
                                       placeholder="VD: 10199" 
                                       value="10199" 
                                       min="0" 
                                       max="99999" 
                                       required>
                                <div class="form-text small" style="font-size: 0.72rem;">Ghép thành: <code>101.99</code></div>
                            </div>
                        </div>

                        <!-- Checkbox lọc biển đẹp -->
                        <div class="p-3 bg-light rounded-3 border mb-4">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="blockSpecial" id="blockSpecialCheck" value="true" checked>
                                <label class="form-check-label small fw-bold text-dark" for="blockSpecialCheck">
                                    <i class="fa-solid fa-shield-cat text-danger me-1"></i> Tự động khóa biển đẹp (Đấu giá)
                                </label>
                                <div class="text-muted small mt-1" style="font-size: 0.74rem;">
                                    Tự động nhận diện Ngũ quý (<code>555.55</code>, <code>999.99</code>), Tứ quý, Sảnh tiến (<code>123.45</code>), Lộc phát để gán trạng thái <code>BLOCKED</code> thay vì cấp ngẫu nhiên.
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-danger w-100 fw-bold py-2.5 shadow-sm">
                            <i class="fa-solid fa-plus-circle me-1"></i> Khởi Tạo Dải Biển Số
                        </button>
                    </form>
                </div>
            </div>

            <!-- CỘT PHẢI: TRA CỨU KHO BIỂN SỐ & KHÓA/MỞ KHÓA (FR-10) -->
            <div class="col-xl-8 col-lg-7">
                <div class="card border-0 shadow-sm h-100 p-4">
                    <div class="section-header justify-content-between">
                        <div class="d-flex align-items-center gap-2">
                            <i class="fa-solid fa-table-list fs-5"></i>
                            <span>Danh Sách Kho Biển Số Toàn Quốc</span>
                        </div>
                        <span class="badge bg-light text-dark border">
                            Hiển thị: <strong><c:out value="${plates.size()}" default="0" /></strong> biển số
                        </span>
                    </div>

                    <!-- FORM LỌC & TÌM KIẾM (FORM GET THUẦN TÚY KHÔNG JS) -->
                    <form action="${pageContext.request.contextPath}/admin/home" method="GET" class="row g-2 align-items-center mb-3">
                        
                        <!-- Lọc theo Quận -->
                        <div class="col-md-4 col-sm-6">
                            <select name="districtId" class="form-select form-select-sm">
                                <option value="0">-- Tất cả Quận/Huyện --</option>
                                <c:forEach var="d" items="${districts}">
                                    <option value="${d.districtId}" <c:if test="${currentDistrictId eq d.districtId}">selected</c:if>>
                                        <c:out value="${d.districtName}" /> (${d.platePrefix})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Lọc theo Trạng thái -->
                        <div class="col-md-3 col-sm-6">
                            <select name="status" class="form-select form-select-sm">
                                <option value="ALL" <c:if test="${currentStatus eq 'ALL'}">selected</c:if>>-- Tất cả trạng thái --</option>
                                <option value="AVAILABLE" <c:if test="${currentStatus eq 'AVAILABLE'}">selected</c:if>>1. Khả dụng (AVAILABLE)</option>
                                <option value="ASSIGNED" <c:if test="${currentStatus eq 'ASSIGNED'}">selected</c:if>>2. Đã cấp (ASSIGNED)</option>
                                <option value="BLOCKED" <c:if test="${currentStatus eq 'BLOCKED'}">selected</c:if>>3. Khóa đấu giá (BLOCKED)</option>
                            </select>
                        </div>

                        <!-- Tìm kiếm từ khóa -->
                        <div class="col-md-3 col-sm-8">
                            <input type="text" 
                                   name="keyword" 
                                   class="form-control form-control-sm" 
                                   placeholder="Nhập biển số..." 
                                   value="<c:out value='${keyword}' />">
                        </div>

                        <div class="col-md-2 col-sm-4 d-flex gap-1">
                            <button type="submit" class="btn btn-danger btn-sm w-100 fw-bold">
                                <i class="fa-solid fa-filter"></i> Lọc
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/home" class="btn btn-outline-secondary btn-sm" title="Đặt lại">
                                <i class="fa-solid fa-rotate-left"></i>
                            </a>
                        </div>
                    </form>

                    <!-- BẢNG DANH SÁCH BIỂN SỐ VÀ THAO TÁC KHÓA/MỞ KHÓA -->
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" style="font-size: 0.88rem;">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 70px;">ID</th>
                                    <th>Biển Số Xe</th>
                                    <th>Địa Bàn Áp Dụng</th>
                                    <th style="width: 140px;">Trạng Thái</th>
                                    <th style="width: 160px;" class="text-end pe-3">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty plates}">
                                        <tr>
                                            <td colspan="5" class="text-center py-5 text-muted">
                                                <i class="fa-solid fa-folder-open fs-2 text-secondary opacity-50 mb-2"></i>
                                                <div>Không tìm thấy biển số nào phù hợp với bộ lọc hiện tại.</div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${plates}">
                                            <tr>
                                                <td class="text-muted font-monospace">#<c:out value="${p.plateId}" /></td>
                                                
                                                <!-- BIỂN SỐ DẬP NỔI -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${p.status eq 'BLOCKED'}">
                                                            <div class="plate-badge-blocked">
                                                                <c:out value="${p.fullPlate}" />
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="plate-badge-vneid">
                                                                <c:out value="${p.fullPlate}" />
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- ĐỊA BÀN -->
                                                <td>
                                                    <div class="fw-semibold text-dark"><c:out value="${p.district.districtName}" /></div>
                                                    <div class="text-muted" style="font-size: 0.72rem;"><c:out value="${p.district.provinceName}" /> (Mã: ${p.district.platePrefix})</div>
                                                </td>

                                                <!-- TRẠNG THÁI -->
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${p.status eq 'AVAILABLE'}">
                                                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                                                <i class="fa-solid fa-circle-check me-1"></i> Khả dụng
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${p.status eq 'ASSIGNED'}">
                                                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                                                <i class="fa-solid fa-lock me-1"></i> Đã cấp định danh
                                                            </span>
                                                            <c:if test="${not empty p.assignedAt}">
                                                                <div class="text-muted" style="font-size: 0.7rem;">
                                                                    <fmt:formatDate value="${p.assignedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                                </div>
                                                            </c:if>
                                                        </c:when>
                                                        <c:when test="${p.status eq 'BLOCKED'}">
                                                            <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">
                                                                <i class="fa-solid fa-gavel me-1"></i> Khóa đấu giá
                                                            </span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>

                                                <!-- THAO TÁC KHÓA / MỞ KHÓA (FORM POST THUẦN TÚY KHÔNG JS) -->
                                                <td class="text-end pe-3">
                                                    <c:choose>
                                                        
                                                        <%-- BIỂN SỐ ĐANG KHẢ DỤNG -> CÓ THỂ KHÓA ĐẤU GIÁ --%>
                                                        <c:when test="${p.status eq 'AVAILABLE'}">
                                                            <form action="${pageContext.request.contextPath}/admin/home" method="POST" class="d-inline">
                                                                <input type="hidden" name="action" value="toggle_status">
                                                                <input type="hidden" name="plateId" value="${p.plateId}">
                                                                <input type="hidden" name="targetStatus" value="BLOCKED">
                                                                <button type="submit" class="btn btn-outline-danger btn-sm py-0.5 px-2" style="font-size: 0.75rem;">
                                                                    <i class="fa-solid fa-lock me-1"></i> Khóa biển
                                                                </button>
                                                            </form>
                                                        </c:when>

                                                        <%-- BIỂN SỐ ĐANG BỊ KHÓA -> CÓ THỂ MỞ KHÓA --%>
                                                        <c:when test="${p.status eq 'BLOCKED'}">
                                                            <form action="${pageContext.request.contextPath}/admin/home" method="POST" class="d-inline">
                                                                <input type="hidden" name="action" value="toggle_status">
                                                                <input type="hidden" name="plateId" value="${p.plateId}">
                                                                <input type="hidden" name="targetStatus" value="AVAILABLE">
                                                                <button type="submit" class="btn btn-outline-success btn-sm py-0.5 px-2" style="font-size: 0.75rem;">
                                                                    <i class="fa-solid fa-lock-open me-1"></i> Mở khóa
                                                                </button>
                                                            </form>
                                                        </c:when>

                                                        <%-- BIỂN SỐ ĐÃ CẤP CHO DÂN -> NGHIÊM CẤM THAY ĐỔI (BR-04) --%>
                                                        <c:otherwise>
                                                            <span class="text-muted small fst-italic" style="font-size: 0.72rem;">
                                                                <i class="fa-solid fa-shield text-primary me-1"></i> Đã cấp định danh
                                                            </span>
                                                        </c:otherwise>

                                                    </c:choose>
                                                </td>

                                            </tr>
                                        </c:forEach>
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
    <footer class="footer-vneid">
        <div class="container-fluid px-lg-4">
            <p class="mb-1 fw-bold text-dark">
                &copy; 2026 Cổng Quản Trị Hệ Thống Đăng Ký Phương Tiện & Kho Biển Số Quốc Gia
            </p>
            <p class="mb-0 text-muted">
                Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Chuẩn nhận diện định danh VNeID &bull; MVC2 Zero JS
            </p>
        </div>
    </footer>

</body>
</html>
