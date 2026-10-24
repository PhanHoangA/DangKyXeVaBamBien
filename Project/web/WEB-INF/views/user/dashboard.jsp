<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Xe Của Bạn - Cổng Dịch Vụ Công Đăng Ký Xe (Chuẩn VNeID)</title>
    <!-- Google Fonts -->
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
            --vneid-gold: #e5a919;
            --vneid-gold-light: #fbe083;
            --text-dark: #1e293b;
            --bg-light: #f8fafc;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Be Vietnam Pro', sans-serif;
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar-vneid {
            background: linear-gradient(135deg, #7a1214 0%, #a81c1e 60%, #c92a2a 100%);
            box-shadow: 0 4px 15px rgba(122, 18, 20, 0.25);
            border-bottom: 2px solid var(--vneid-gold);
            padding: 12px 0;
        }

        .navbar-brand {
            font-weight: 800;
            color: #ffffff !important;
            font-size: 1.15rem;
            display: flex;
            align-items: center;
            gap: 12px;
            text-transform: uppercase;
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

        .user-badge-nav {
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(251, 224, 131, 0.4);
            border-radius: 30px;
            padding: 6px 14px;
            color: #ffffff;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.88rem;
        }

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

    <!-- KIỂM TRA ĐĂNG NHẬP -->
    <c:if test="${empty sessionScope.currentUser}">
        <c:redirect url="/login" />
    </c:if>

    <!-- NAVBAR HEADER -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-vneid">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home.jsp">
                <div class="brand-emblem">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <div>Cổng Dịch Vụ Công Đăng Ký Phương Tiện</div>
                    <div style="font-size: 0.72rem; color: var(--vneid-gold-light); font-weight: 500;">
                        Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Chuẩn VNeID
                    </div>
                </div>
            </a>

            <div class="d-flex align-items-center gap-3">
                <div class="user-badge-nav d-none d-md-flex">
                    <i class="fa-solid fa-circle-user fs-5 text-warning"></i>
                    <div>
                        <div class="fw-bold"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                        <div style="font-size: 0.72rem; color: rgba(255,255,255,0.75);">
                            <c:out value="${sessionScope.currentUser.district.districtName}" /> (${sessionScope.currentUser.district.platePrefix})
                        </div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-light btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-house me-1"></i> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-right-from-bracket me-1"></i> Đăng xuất
                </a>
            </div>
        </div>
    </nav>

    <!-- NỘI DUNG CHÍNH -->
    <main class="container my-4">

        <!-- FLASH MESSAGE -->
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

        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
            <div>
                <h4 class="fw-bold mb-1 text-dark">
                    <i class="fa-solid fa-folder-closed text-danger me-2"></i>Danh Sách Phương Tiện Đã Khai Báo
                </h4>
                <div class="text-muted small">
                    Theo dõi tiến độ thẩm định của Cán bộ CSGT và trạng thái cấp mã bấm biển số.
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/user/vehicle-form" class="btn btn-danger fw-bold shadow-sm">
                <i class="fa-solid fa-plus me-1"></i> Khai Báo Xe Mới (FR-03)
            </a>
        </div>

        <!-- BẢNG DANH SÁCH HỒ SƠ CÔNG DÂN -->
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem;">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-3" style="width: 90px;">Mã HS</th>
                                <th>Thông Tin Xe Máy</th>
                                <th style="width: 220px;">Số Khung / Số Máy</th>
                                <th style="width: 140px;">Ngày Nộp</th>
                                <th style="width: 160px;">Trạng Thái</th>
                                <th style="width: 200px;" class="pe-3">Mã Bấm / Biển Số Cấp</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty userRegistrations}">
                                    <tr>
                                        <td colspan="6" class="text-center py-5 text-muted">
                                            <i class="fa-solid fa-motorcycle fs-1 text-secondary opacity-50 mb-2"></i>
                                            <div>Bạn chưa nộp hồ sơ đăng ký phương tiện nào.</div>
                                            <a href="${pageContext.request.contextPath}/user/vehicle-form" class="btn btn-outline-danger btn-sm mt-3 fw-bold">
                                                <i class="fa-solid fa-plus me-1"></i> Bắt đầu khai báo xe ngay
                                            </a>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="reg" items="${userRegistrations}">
                                        <tr>
                                            <td class="ps-3 fw-bold text-dark">#<c:out value="${reg.registrationId}" /></td>
                                            
                                            <td>
                                                <div class="fw-bold text-danger">
                                                    <c:out value="${reg.vehicle.brand.brandName}" /> &bull; <c:out value="${reg.vehicle.modelName}" />
                                                    <span class="badge bg-light text-dark border ms-1"><c:out value="${reg.vehicle.type.typeName}" /></span>
                                                </div>
                                                <div class="text-muted small">
                                                    Màu: <strong><c:out value="${reg.vehicle.color}" /></strong> &bull; Dung tích: <strong><c:out value="${reg.vehicle.engineCapacity}" /> cc</strong>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.74rem;">
                                                    Giá trị khai báo: <strong class="text-success"><fmt:formatNumber value="${reg.vehicle.vehicleValue}" type="number" maxFractionDigits="0" /> đ</strong>
                                                </div>
                                            </td>

                                            <td>
                                                <div class="small">Số khung: <code class="fw-bold text-dark"><c:out value="${reg.vehicle.chassisNumber}" /></code></div>
                                                <div class="small">Số máy: <code class="fw-bold text-dark"><c:out value="${reg.vehicle.engineNumber}" /></code></div>
                                            </td>

                                            <td class="text-muted small">
                                                <fmt:formatDate value="${reg.submittedAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </td>

                                            <td>
                                                <span class="badge <c:out value='${reg.statusBadgeClass}' /> px-2 py-1">
                                                    <c:out value="${reg.statusTitle}" />
                                                </span>

                                                <c:if test="${not empty reg.rejectionReason}">
                                                    <div class="text-danger small mt-1" style="font-size: 0.75rem;">
                                                        <i class="fa-solid fa-circle-exclamation me-1"></i>Lý do từ chối: <c:out value="${reg.rejectionReason}" />
                                                    </div>
                                                </c:if>
                                            </td>

                                            <td class="pe-3">
                                                <c:choose>
                                                    <c:when test="${reg.status eq 'DRAWN'}">
                                                        <div class="plate-badge-vneid mb-1">
                                                            <c:out value="${reg.plate.fullPlate}" />
                                                        </div>
                                                        <div class="text-success small fw-bold" style="font-size: 0.72rem;">
                                                            <i class="fa-solid fa-circle-check me-1"></i>Đã cấp định danh
                                                        </div>
                                                    </c:when>

                                                    <c:when test="${reg.status eq 'APPROVED'}">
                                                        <div class="draw-code-badge mb-1">
                                                            <i class="fa-solid fa-ticket me-1"></i><c:out value="${reg.drawCode}" />
                                                        </div>
                                                        <div class="small text-muted" style="font-size: 0.72rem;">
                                                            Lệ phí: <fmt:formatNumber value="${reg.feeAmount}" type="number" maxFractionDigits="0" /> đ
                                                        </div>
                                                        <a href="${pageContext.request.contextPath}/user/draw-plate?registrationId=${reg.registrationId}" class="btn btn-warning btn-sm fw-bold w-100 mt-1" style="font-size: 0.75rem;">
                                                            <i class="fa-solid fa-dice me-1"></i> Bấm Biển Số Ngay
                                                        </a>
                                                    </c:when>

                                                    <c:when test="${reg.status eq 'PENDING'}">
                                                        <span class="text-muted small fst-italic">Đang chờ CSGT duyệt</span>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <span class="text-muted small fst-italic">Cần nộp lại</span>
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

    </main>

    <!-- FOOTER -->
    <footer class="footer-vneid">
        <div class="container">
            <p class="mb-1 fw-bold text-dark">
                &copy; 2026 Cổng Dịch Vụ Công Đăng Ký & Bấm Biển Số Xe Máy Trực Tuyến
            </p>
            <p class="mb-0 text-muted">
                Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Chuẩn nhận diện định danh VNeID
            </p>
        </div>
    </footer>

</body>
</html>
