<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cán Bộ Thẩm Định - Tiếp Nhận Hồ Sơ & Cấp Mã Bấm Biển (Chuẩn VNeID)</title>
    <!-- Google Fonts: Be Vietnam Pro & Montserrat -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&family=Montserrat:wght@600;700;800&display=swap" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --vneid-red: #a81c1e;
            --vneid-red-dark: #7a1214;
            --vneid-red-light: #c92a2a;
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

        /* Top Navbar Cán Bộ CSGT */
        .navbar-officer {
            background: linear-gradient(135deg, #4f0a0d 0%, #7a1214 45%, #a81c1e 100%);
            box-shadow: 0 4px 15px rgba(122, 18, 20, 0.3);
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

        .officer-badge-nav {
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

        /* Banner thông tin địa bàn thẩm định */
        .district-banner {
            background: linear-gradient(135deg, #180304 0%, #3d070a 60%, #610d10 100%);
            border: 1px solid rgba(229, 169, 25, 0.4);
            border-radius: 12px;
            color: #ffffff;
            padding: 20px 24px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 24px;
        }

        /* Thẻ thống kê KPI */
        .stat-card-link {
            text-decoration: none;
            color: inherit;
            display: block;
            height: 100%;
        }

        .stat-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 16px 20px;
            border: 1.5px solid #e2e8f0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.08);
        }

        .stat-card.active {
            border-color: var(--vneid-red);
            background: #fff8f8;
            box-shadow: 0 4px 12px rgba(168, 28, 30, 0.15);
        }

        .stat-card.border-pending { border-left: 5px solid #d97706; }
        .stat-card.border-approved { border-left: 5px solid #0284c7; }
        .stat-card.border-drawn { border-left: 5px solid #16a34a; }
        .stat-card.border-rejected { border-left: 5px solid #dc2626; }
        .stat-card.border-all { border-left: 5px solid #475569; }

        .stat-count {
            font-family: 'Montserrat', sans-serif;
            font-size: 1.8rem;
            font-weight: 800;
            line-height: 1.1;
        }

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

        /* Mã Draw Code */
        .draw-code-badge {
            background: #fffbeb;
            color: #b45309;
            border: 1.5px solid #f59e0b;
            border-radius: 6px;
            padding: 4px 10px;
            font-family: 'Montserrat', monospace;
            font-weight: 800;
            font-size: 0.92rem;
            display: inline-block;
            letter-spacing: 1px;
        }

        /* Khối thẩm định trong từng dòng hồ sơ PENDING */
        .review-box {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
            padding: 10px;
            margin-top: 6px;
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

    <!-- TOP NAVBAR CÁN BỘ TIẾP NHẬN & THẨM ĐỊNH -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-officer">
        <div class="container-fluid px-lg-4">
            <a class="navbar-brand d-flex align-items-center gap-3 text-white fw-bold text-decoration-none" href="${pageContext.request.contextPath}/officer/registrations">
                <div class="brand-emblem">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <div style="font-size: 1.1rem; text-transform: uppercase; letter-spacing: 0.5px;">Cổng Thẩm Định Hồ Sơ & Cấp Mã Bấm Biển</div>
                    <div style="font-size: 0.72rem; color: var(--vneid-gold-light); font-weight: 500;">
                        Cục Cảnh Sát Giao Thông &bull; Bộ Công An
                    </div>
                </div>
            </a>

            <div class="d-flex align-items-center gap-3">
                <div class="officer-badge-nav">
                    <i class="fa-solid fa-user-shield fs-5 text-warning"></i>
                    <div>
                        <div class="fw-bold"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                        <div style="font-size: 0.72rem; color: rgba(255,255,255,0.85);">
                            Cán bộ CSGT: <c:out value="${sessionScope.currentUser.district.districtName}" /> (<c:out value="${sessionScope.currentUser.district.platePrefix}" />)
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-warning btn-sm rounded-pill px-3 text-warning border-warning">
                    <i class="fa-solid fa-house me-1"></i> Cổng dịch vụ công
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
                <i class="fa-solid fa-circle-exclamation fs-5 text-danger"></i>
                <div class="fw-medium"><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- BANNER THÔNG TIN ĐỊA BÀN PHỤ TRÁCH (BR-01) -->
        <div class="district-banner d-flex flex-wrap justify-content-between align-items-center gap-3">
            <div>
                <div class="d-flex align-items-center gap-2 mb-1">
                    <span class="badge bg-warning text-dark fw-bold px-2 py-1" style="font-size: 0.72rem;">
                        <i class="fa-solid fa-scale-balanced me-1"></i> ĐỊA BÀN THẨM ĐỊNH
                    </span>
                    <span class="text-white-50 small">Hệ thống cấp biển số xe máy định danh</span>
                </div>
                <h3 class="fw-bold text-white mb-1">
                    Công An <c:out value="${sessionScope.currentUser.district.districtName}" /> &bull; <c:out value="${sessionScope.currentUser.district.provinceName}" />
                </h3>
                <div class="text-white-50 small">
                    <i class="fa-solid fa-tag text-warning me-1"></i> Dải đầu biển số ấn định: 
                    <strong class="text-warning fs-6"><c:out value="${sessionScope.currentUser.district.platePrefix}" /></strong> 
                    &bull; Chỉ tiếp nhận và cấp mã dự thưởng cho hồ sơ thuộc địa bàn thường trú này.
                </div>
            </div>

            <div class="text-end">
                <div class="text-white-50 small mb-1">Cán bộ phụ trách tiếp nhận:</div>
                <div class="fw-bold text-white fs-5"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                <div class="badge bg-light text-dark font-monospace">CCCD: <c:out value="${sessionScope.currentUser.identityCard}" /></div>
            </div>
        </div>

        <!-- HÀNG 5 THẺ THỐNG KÊ KPI & BỘ LỌC NHANH (THUẦN THẺ A KHÔNG JS) -->
        <div class="row g-3 mb-4">
            
            <!-- Tất cả hồ sơ -->
            <div class="col-md-2 col-sm-4 col-6">
                <a href="${pageContext.request.contextPath}/officer/registrations?status=ALL" class="stat-card-link">
                    <div class="stat-card border-all <c:if test="${currentStatus eq 'ALL'}">active</c:if>">
                        <div class="text-muted small fw-bold text-uppercase">Tất Cả Hồ Sơ</div>
                        <div class="stat-count text-dark mt-1">
                            <c:out value="${stats['ALL']}" default="0" />
                        </div>
                        <div class="text-muted" style="font-size: 0.72rem;">Toàn bộ hồ sơ địa bàn</div>
                    </div>
                </a>
            </div>

            <!-- Chờ thẩm định (PENDING) -->
            <div class="col-md-3 col-sm-4 col-6">
                <a href="${pageContext.request.contextPath}/officer/registrations?status=PENDING" class="stat-card-link">
                    <div class="stat-card border-pending <c:if test="${currentStatus eq 'PENDING'}">active</c:if>">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-warning fw-bold small text-uppercase">Chờ Thẩm Định</span>
                            <span class="badge bg-warning text-dark"><i class="fa-solid fa-bell"></i> Cần xử lý</span>
                        </div>
                        <div class="stat-count text-warning mt-1">
                            <c:out value="${stats['PENDING']}" default="0" />
                        </div>
                        <div class="text-muted" style="font-size: 0.72rem;">Chờ cấp mã bấm biển</div>
                    </div>
                </a>
            </div>

            <!-- Đã duyệt chờ bấm biển (APPROVED) -->
            <div class="col-md-3 col-sm-4 col-6">
                <a href="${pageContext.request.contextPath}/officer/registrations?status=APPROVED" class="stat-card-link">
                    <div class="stat-card border-approved <c:if test="${currentStatus eq 'APPROVED'}">active</c:if>">
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="text-info fw-bold small text-uppercase">Đã Cấp Mã Bấm</span>
                            <span class="badge bg-info text-dark"><i class="fa-solid fa-ticket"></i> Đã cấp DrawCode</span>
                        </div>
                        <div class="stat-count text-info mt-1">
                            <c:out value="${stats['APPROVED']}" default="0" />
                        </div>
                        <div class="text-muted" style="font-size: 0.72rem;">Người dân chưa quay số</div>
                    </div>
                </a>
            </div>

            <!-- Đã cấp biển số (DRAWN) -->
            <div class="col-md-2 col-sm-6 col-6">
                <a href="${pageContext.request.contextPath}/officer/registrations?status=DRAWN" class="stat-card-link">
                    <div class="stat-card border-drawn <c:if test="${currentStatus eq 'DRAWN'}">active</c:if>">
                        <div class="text-success fw-bold small text-uppercase">Đã Bấm Biển</div>
                        <div class="stat-count text-success mt-1">
                            <c:out value="${stats['DRAWN']}" default="0" />
                        </div>
                        <div class="text-muted" style="font-size: 0.72rem;">Hoàn tất cấp biển số</div>
                    </div>
                </a>
            </div>

            <!-- Bị từ chối (REJECTED) -->
            <div class="col-md-2 col-sm-6 col-6">
                <a href="${pageContext.request.contextPath}/officer/registrations?status=REJECTED" class="stat-card-link">
                    <div class="stat-card border-rejected <c:if test="${currentStatus eq 'REJECTED'}">active</c:if>">
                        <div class="text-danger fw-bold small text-uppercase">Đã Từ Chối</div>
                        <div class="stat-count text-danger mt-1">
                            <c:out value="${stats['REJECTED']}" default="0" />
                        </div>
                        <div class="text-muted" style="font-size: 0.72rem;">Hồ sơ sai lệch</div>
                    </div>
                </a>
            </div>

        </div>

        <!-- THANH CÔNG CỤ TÌM KIẾM & LỌC HỒ SƠ (FORM GET THUẦN TÚY KHÔNG JS) -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body p-3">
                <form method="GET" action="${pageContext.request.contextPath}/officer/registrations" class="row g-2 align-items-center">
                    
                    <div class="col-lg-3 col-md-4">
                        <label class="form-label small fw-bold text-muted mb-1">Trạng thái hồ sơ:</label>
                        <select name="status" class="form-select form-select-sm">
                            <option value="ALL" <c:if test="${currentStatus eq 'ALL'}">selected</c:if>>-- Tất cả trạng thái --</option>
                            <option value="PENDING" <c:if test="${currentStatus eq 'PENDING'}">selected</c:if>>1. Chờ thẩm định (PENDING)</option>
                            <option value="APPROVED" <c:if test="${currentStatus eq 'APPROVED'}">selected</c:if>>2. Đã cấp mã bấm biển (APPROVED)</option>
                            <option value="DRAWN" <c:if test="${currentStatus eq 'DRAWN'}">selected</c:if>>3. Đã cấp biển số (DRAWN)</option>
                            <option value="REJECTED" <c:if test="${currentStatus eq 'REJECTED'}">selected</c:if>>4. Đã từ chối trả lại (REJECTED)</option>
                        </select>
                    </div>

                    <div class="col-lg-6 col-md-5">
                        <label class="form-label small fw-bold text-muted mb-1">Tìm kiếm hồ sơ:</label>
                        <div class="input-group input-group-sm">
                            <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                            <input type="text" 
                                   name="keyword" 
                                   class="form-control" 
                                   value="<c:out value='${keyword}' />"
                                   placeholder="Nhập số CCCD (12 số), Số khung, Số máy hoặc Họ tên chủ xe...">
                        </div>
                    </div>

                    <div class="col-lg-3 col-md-3 d-flex gap-2 pt-lg-4 pt-md-4">
                        <button type="submit" class="btn btn-danger btn-sm w-100 fw-bold">
                            <i class="fa-solid fa-filter me-1"></i> Tra cứu hồ sơ
                        </button>
                        <a href="${pageContext.request.contextPath}/officer/registrations" class="btn btn-outline-secondary btn-sm px-3" title="Đặt lại bộ lọc">
                            <i class="fa-solid fa-rotate-left"></i>
                        </a>
                    </div>

                </form>
            </div>
        </div>

        <!-- BẢNG DANH SÁCH TIẾP NHẬN & THẨM ĐỊNH HỒ SƠ -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                <h5 class="mb-0 fw-bold text-dark">
                    <i class="fa-solid fa-list-check text-danger me-2"></i>Danh Sách Hồ Sơ Đăng Ký Phương Tiện
                </h5>
                <span class="badge bg-light text-muted border">
                    Tìm thấy: <strong><c:out value="${registrations.size()}" default="0" /></strong> hồ sơ
                </span>
            </div>

            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" style="font-size: 0.88rem;">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-3" style="width: 80px;">Mã HS</th>
                                <th style="width: 200px;">Chủ Phương Tiện</th>
                                <th>Thông Tin Xe & Đăng Ký</th>
                                <th style="width: 140px;">Trạng Thái</th>
                                <th style="width: 180px;">Mã Bấm Biển / Biển Số</th>
                                <th style="width: 320px;" class="pe-3">Thẩm Định & Cấp Mã</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty registrations}">
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <i class="fa-solid fa-folder-open fs-1 text-secondary opacity-50 mb-2"></i>
                                            <div>Không có hồ sơ đăng ký phương tiện nào phù hợp với bộ lọc hiện tại.</div>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="reg" items="${registrations}">
                                        <tr <c:if test="${reg.status eq 'PENDING'}">class="table-warning bg-opacity-10"</c:if>>
                                            
                                            <!-- CỘT 1: MÃ HỒ SƠ & NGÀY NỘP -->
                                            <td class="ps-3 align-top pt-3">
                                                <div class="fw-bold fs-6 text-dark">#<c:out value="${reg.registrationId}" /></div>
                                                <div class="text-muted" style="font-size: 0.74rem;">
                                                    <fmt:formatDate value="${reg.submittedAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </td>

                                            <!-- CỘT 2: CHỦ PHƯƠNG TIỆN -->
                                            <td class="align-top pt-3">
                                                <div class="fw-bold text-dark"><c:out value="${reg.owner.fullName}" /></div>
                                                <div class="font-monospace text-primary fw-semibold" style="font-size: 0.8rem;">
                                                    <i class="fa-solid fa-id-card me-1"></i><c:out value="${reg.owner.identityCard}" />
                                                </div>
                                                <div class="text-muted small">
                                                    <i class="fa-solid fa-phone me-1"></i><c:out value="${reg.owner.phone}" />
                                                </div>
                                                <div class="text-muted" style="font-size: 0.74rem;">
                                                    <c:out value="${reg.owner.address}" />
                                                </div>
                                            </td>

                                            <!-- CỘT 3: THÔNG TIN XE MÁY -->
                                            <td class="align-top pt-3">
                                                <div class="fw-bold text-danger">
                                                    <c:out value="${reg.vehicle.brand.brandName}" /> &bull; <c:out value="${reg.vehicle.modelName}" />
                                                    <span class="badge bg-light text-dark border ms-1"><c:out value="${reg.vehicle.type.typeName}" /></span>
                                                </div>
                                                
                                                <div class="row g-1 mt-1 small">
                                                    <div class="col-sm-6">
                                                        <span class="text-muted">Số khung:</span> 
                                                        <code class="fw-bold text-dark"><c:out value="${reg.vehicle.chassisNumber}" /></code>
                                                    </div>
                                                    <div class="col-sm-6">
                                                        <span class="text-muted">Số máy:</span> 
                                                        <code class="fw-bold text-dark"><c:out value="${reg.vehicle.engineNumber}" /></code>
                                                    </div>
                                                    <div class="col-sm-6">
                                                        <span class="text-muted">Dung tích:</span> 
                                                        <strong><c:out value="${reg.vehicle.engineCapacity}" /> cc</strong> - Màu: <strong><c:out value="${reg.vehicle.color}" /></strong>
                                                    </div>
                                                    <div class="col-sm-6">
                                                        <span class="text-muted">Giá trị xe:</span> 
                                                        <strong class="text-success">
                                                            <fmt:formatNumber value="${reg.vehicle.vehicleValue}" type="number" maxFractionDigits="0" /> đ
                                                        </strong>
                                                    </div>
                                                    <div class="col-sm-6 text-muted" style="font-size: 0.72rem;">
                                                        Biên lai thuế: <strong><c:out value="${reg.vehicle.taxReceiptNumber}" /></strong>
                                                    </div>
                                                    <div class="col-sm-6 text-muted" style="font-size: 0.72rem;">
                                                        Hóa đơn VAT: <strong><c:out value="${reg.vehicle.invoiceNumber}" /></strong>
                                                    </div>
                                                </div>
                                            </td>

                                            <!-- CỘT 4: TRẠNG THÁI HỒ SƠ -->
                                            <td class="align-top pt-3">
                                                <span class="badge <c:out value='${reg.statusBadgeClass}' /> px-2 py-1">
                                                    <c:out value="${reg.statusTitle}" />
                                                </span>

                                                <c:if test="${not empty reg.rejectionReason}">
                                                    <div class="text-danger small mt-1" style="font-size: 0.75rem;">
                                                        <i class="fa-solid fa-circle-exclamation me-1"></i>Lý do: <c:out value="${reg.rejectionReason}" />
                                                    </div>
                                                </c:if>
                                            </td>

                                            <!-- CỘT 5: MÃ BẤM BIỂN HOẶC BIỂN SỐ ĐÃ CẤP -->
                                            <td class="align-top pt-3">
                                                <c:choose>
                                                    <c:when test="${reg.status eq 'DRAWN'}">
                                                        <div class="plate-badge-vneid mb-1">
                                                            <c:out value="${reg.plate.fullPlate}" />
                                                        </div>
                                                        <div class="text-success small fw-bold" style="font-size: 0.72rem;">
                                                            <i class="fa-solid fa-circle-check me-1"></i>Đã cấp định danh
                                                        </div>
                                                        <div class="text-muted" style="font-size: 0.7rem;">
                                                            Cấp lúc: <fmt:formatDate value="${reg.drawnAt}" pattern="dd/MM/yyyy HH:mm" />
                                                        </div>
                                                    </c:when>

                                                    <c:when test="${reg.status eq 'APPROVED'}">
                                                        <div class="draw-code-badge mb-1">
                                                            <i class="fa-solid fa-key me-1"></i><c:out value="${reg.drawCode}" />
                                                        </div>
                                                        <div class="small text-muted" style="font-size: 0.74rem;">
                                                            Lệ phí: <strong class="text-dark"><fmt:formatNumber value="${reg.feeAmount}" type="number" maxFractionDigits="0" /> đ</strong>
                                                        </div>
                                                        <div class="text-info small fw-bold" style="font-size: 0.7rem;">
                                                            <i class="fa-solid fa-spinner fa-spin me-1"></i>Chờ công dân bấm số
                                                        </div>
                                                    </c:when>

                                                    <c:when test="${reg.status eq 'PENDING'}">
                                                        <span class="text-muted small fst-italic">Chờ thẩm định</span>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <span class="text-muted small fst-italic">Chưa có mã</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <!-- CỘT 6: THAO TÁC CỦA CÁN BỘ (FORM POST THUẦN TÚY KHÔNG JS) -->
                                            <td class="align-top pt-2 pe-3">
                                                <c:choose>
                                                    
                                                    <%-- HỒ SƠ CHỜ THẨM ĐỊNH (PENDING) -> HIỂN THỊ BIỂU MẪU DUYỆT & TỪ CHỐI --%>
                                                    <c:when test="${reg.status eq 'PENDING'}">
                                                        <div class="review-box">
                                                            
                                                            <!-- 1. BIỂU MẪU PHÊ DUYỆT VÀ CẤP MÃ BẤM BIỂN (FR-07) -->
                                                            <form action="${pageContext.request.contextPath}/officer/review" method="POST" class="mb-2 pb-2 border-bottom">
                                                                <input type="hidden" name="registrationId" value="${reg.registrationId}">
                                                                <input type="hidden" name="action" value="approve">

                                                                <div class="input-group input-group-sm mb-1">
                                                                    <span class="input-group-text bg-white text-muted" style="font-size: 0.75rem;">Lệ phí (đ):</span>
                                                                    <input type="number" 
                                                                           name="feeAmount" 
                                                                           class="form-control form-control-sm font-monospace fw-bold" 
                                                                           value="100000" 
                                                                           min="10000" 
                                                                           step="10000" 
                                                                           required>
                                                                    <button type="submit" class="btn btn-success btn-sm fw-bold px-2">
                                                                        <i class="fa-solid fa-check me-1"></i> Duyệt & Cấp Mã
                                                                    </button>
                                                                </div>
                                                                <div class="text-muted" style="font-size: 0.7rem;">
                                                                    * Tự động sinh mã <code>DRAW-XXXXXX</code> cho người dân quay biển.
                                                                </div>
                                                            </form>

                                                            <!-- 2. BIỂU MẪU TỪ CHỐI KÈM LÝ DO SAI LỆCH (FR-08) -->
                                                            <form action="${pageContext.request.contextPath}/officer/review" method="POST">
                                                                <input type="hidden" name="registrationId" value="${reg.registrationId}">
                                                                <input type="hidden" name="action" value="reject">

                                                                <div class="input-group input-group-sm">
                                                                    <input type="text" 
                                                                           name="rejectionReason" 
                                                                           class="form-control form-control-sm" 
                                                                           placeholder="Nhập lý do sai số khung/hóa đơn..." 
                                                                           maxlength="225" 
                                                                           required>
                                                                    <button type="submit" class="btn btn-outline-danger btn-sm fw-bold">
                                                                        <i class="fa-solid fa-xmark me-1"></i> Trả lại
                                                                    </button>
                                                                </div>
                                                            </form>

                                                        </div>
                                                    </c:when>

                                                    <%-- HỒ SƠ ĐÃ DUYỆT (APPROVED) --%>
                                                    <c:when test="${reg.status eq 'APPROVED'}">
                                                        <div class="p-2 rounded bg-light border border-info border-opacity-25 text-muted" style="font-size: 0.76rem;">
                                                            <i class="fa-solid fa-circle-check text-info me-1"></i>
                                                            Đã duyệt bởi <strong><c:out value="${not empty reg.officer.fullName ? reg.officer.fullName : 'Cán bộ CSGT'}" /></strong>.
                                                            <br>Công dân có thể đăng nhập vào tài khoản để bấm biển số bất cứ lúc nào.
                                                        </div>
                                                    </c:when>

                                                    <%-- HỒ SƠ ĐÃ BẤM BIỂN XONG (DRAWN) --%>
                                                    <c:when test="${reg.status eq 'DRAWN'}">
                                                        <div class="p-2 rounded bg-light border border-success border-opacity-25 text-muted" style="font-size: 0.76rem;">
                                                            <i class="fa-solid fa-lock text-success me-1"></i>
                                                            Đã hoàn tất cấp biển số <strong><c:out value="${reg.plate.fullPlate}" /></strong>. Dữ liệu định danh bất biến trên hệ thống.
                                                        </div>
                                                    </c:when>

                                                    <%-- HỒ SƠ BỊ TỪ CHỐI (REJECTED) --%>
                                                    <c:otherwise>
                                                        <div class="p-2 rounded bg-light border border-danger border-opacity-25 text-muted" style="font-size: 0.76rem;">
                                                            <i class="fa-solid fa-clock-rotate-left text-danger me-1"></i>
                                                            Hồ sơ đã trả về cho công dân chỉnh sửa nộp lại.
                                                        </div>
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

            <!-- CHÂN BẢNG TỔNG KẾT VÀ HƯỚNG DẪN NGHIỆP VỤ -->
            <div class="card-footer bg-light py-2.5 px-3 d-flex flex-wrap justify-content-between align-items-center text-muted small">
                <div>
                    <i class="fa-solid fa-circle-info text-primary me-1"></i>
                    <strong>Quy trình xử lý hồ sơ (SRS):</strong> 
                    <code>PENDING</code> (Cán bộ duyệt cấp mã) &rarr; <code>APPROVED</code> (Công dân bấm biển ngẫu nhiên) &rarr; <code>DRAWN</code> (Cấp biển định danh thành công).
                </div>
                <div>
                    Đơn vị: <strong>Đội CSGT - Công An <c:out value="${sessionScope.currentUser.district.districtName}" /></strong>
                </div>
            </div>

        </div>

    </main>

    <!-- FOOTER HỆ THỐNG -->
    <footer class="footer-vneid">
        <div class="container-fluid px-lg-4">
            <p class="mb-1 fw-bold text-dark">
                &copy; 2026 Cổng Tiếp Nhận & Thẩm Định Đăng Ký Phương Tiện Xe Máy Trực Tuyến
            </p>
            <p class="mb-0 text-muted">
                Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Chuẩn định danh VNeID &bull; MVC2 (Thuần JSP/Servlet/JDBC/JSTL)
            </p>
        </div>
    </footer>

</body>
</html>
