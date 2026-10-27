<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phòng Bấm Biển Số Xe Máy Ngẫu Nhiên - Chuẩn VNeID</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&family=Montserrat:wght@700;800;900&display=swap" rel="stylesheet">
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

        /* Khung Biển Số Xe Mô Phỏng Chuẩn Bộ Công An */
        .license-plate-real {
            width: 320px;
            height: 180px;
            background: #ffffff;
            border: 4px solid #1e293b;
            border-radius: 16px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2), inset 0 0 8px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            margin: 0 auto;
            color: #1e293b;
            font-family: 'Montserrat', monospace;
            font-weight: 900;
            user-select: none;
        }

        .license-plate-real::before {
            content: "•";
            position: absolute;
            top: 6px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 14px;
            color: #64748b;
        }

        .plate-prefix-row {
            font-size: 2.2rem;
            letter-spacing: 3px;
            line-height: 1.1;
        }

        .plate-number-row {
            font-size: 2.7rem;
            letter-spacing: 4px;
            line-height: 1.1;
            margin-top: 4px;
        }

        .license-plate-placeholder {
            width: 320px;
            height: 180px;
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            border: 4px dashed var(--vneid-gold);
            border-radius: 16px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            margin: 0 auto;
            color: var(--vneid-gold-light);
            font-family: 'Montserrat', monospace;
            font-weight: 900;
        }

        /* Nút bấm biển số VNeID siêu nổi bật */
        .btn-draw-plate {
            background: linear-gradient(135deg, #e5a919 0%, #d97706 100%);
            border: 2px solid #fff3c4;
            color: #180304;
            font-weight: 800;
            font-size: 1.25rem;
            padding: 16px 36px;
            border-radius: 50px;
            letter-spacing: 1px;
            box-shadow: 0 8px 24px rgba(229, 169, 25, 0.4);
            transition: all 0.2s ease;
        }

        .btn-draw-plate:hover {
            background: linear-gradient(135deg, #f59e0b 0%, #b45309 100%);
            color: #ffffff;
            transform: translateY(-3px) scale(1.02);
            box-shadow: 0 12px 30px rgba(229, 169, 25, 0.6);
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

    <!-- THANH ĐIỀU HƯỚNG VNeID HEADER -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-vneid">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home.jsp">
                <div class="brand-emblem">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <div>Hệ Thống Bấm Biển Số Trực Tuyến</div>
                    <div style="font-size: 0.72rem; color: var(--vneid-gold-light); font-weight: 500;">
                        Cục Cảnh Sát Giao Thông &bull; Bộ Công An
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
    <main class="container my-4" style="max-width: 860px;">

        <!-- BREADCRUMB -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb small">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home.jsp" class="text-danger text-decoration-none">Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/user/dashboard" class="text-danger text-decoration-none">Hồ sơ của bạn</a></li>
                <li class="breadcrumb-item active" aria-current="page">Bấm biển số ngẫu nhiên</li>
            </ol>
        </nav>

        <!-- THÔNG BÁO LỖI NẾU CÓ -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center gap-2 mb-4">
                <i class="fa-solid fa-triangle-exclamation fs-4 text-danger"></i>
                <div class="fw-semibold"><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- TRƯỜNG HỢP 1: BẤM BIỂN THÀNH CÔNG -> HIỂN THỊ KẾT QUẢ RỰC RỠ -->
        <c:if test="${not empty drawnPlate}">
            <div class="card border-0 shadow-lg text-center p-4 p-md-5 mb-4" style="background: linear-gradient(135deg, #180304 0%, #3e070a 60%, #5c0b0f 100%); border: 2px solid var(--vneid-gold) !important; border-radius: 16px;">
                
                <div class="badge bg-warning text-dark fw-bold px-3 py-2 mb-3 mx-auto" style="font-size: 0.9rem; letter-spacing: 0.5px;">
                    <i class="fa-solid fa-circle-check me-1"></i> BẤM BIỂN THÀNH CÔNG &bull; ĐỊNH DANH THEO CCCD
                </div>

                <h3 class="text-white fw-bold mb-1">CHÚC MỪNG CHỦ PHƯƠNG TIỆN!</h3>
                <p class="text-white-50 small mb-4">
                    Biển số xe đã được ghi nhận chính thức vào Cơ sở dữ liệu Quốc gia về Giao thông đường bộ.
                </p>

                <!-- KHUNG BIỂN SỐ XE VỪA BỐC ĐƯỢC -->
                <div class="license-plate-real mb-4">
                    <div class="plate-prefix-row"><c:out value="${selectedRegistration.district.platePrefix}" /></div>
                    <div class="plate-number-row"><c:out value="${drawnPlate.plateNumber}" /></div>
                </div>

                <div class="card bg-white text-dark p-3 text-start mb-4 mx-auto" style="max-width: 500px; border-radius: 10px;">
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-2">
                        <span class="text-muted small">Biển số định danh:</span>
                        <span class="fw-bold text-danger fs-6"><c:out value="${drawnPlate.fullPlate}" /></span>
                    </div>
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-2">
                        <span class="text-muted small">Chủ sở hữu (CCCD):</span>
                        <span class="fw-bold"><c:out value="${sessionScope.currentUser.fullName}" /> (<c:out value="${sessionScope.currentUser.identityCard}" />)</span>
                    </div>
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-2">
                        <span class="text-muted small">Phương tiện:</span>
                        <span class="fw-semibold"><c:out value="${selectedRegistration.vehicle.brand.brandName}" /> &bull; <c:out value="${selectedRegistration.vehicle.modelName}" /></span>
                    </div>
                    <div class="d-flex justify-content-between border-bottom pb-2 mb-2">
                        <span class="text-muted small">Số khung:</span>
                        <code class="fw-bold"><c:out value="${selectedRegistration.vehicle.chassisNumber}" /></code>
                    </div>
                    <div class="d-flex justify-content-between">
                        <span class="text-muted small">Số máy:</span>
                        <code class="fw-bold"><c:out value="${selectedRegistration.vehicle.engineNumber}" /></code>
                    </div>
                </div>

                <div class="text-white-50 small mb-4">
                    <i class="fa-solid fa-lock text-warning me-1"></i> Biển số này có giá trị định danh vĩnh viễn với tài khoản của bạn, không thể thu hồi hoặc bấm lại.
                </div>

                <div class="d-flex justify-content-center gap-3">
                    <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-warning fw-bold px-4 py-2 text-dark">
                        <i class="fa-solid fa-list-check me-1"></i> Xem Danh Sách Xe Của Bạn
                    </a>
                    <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-light px-4 py-2">
                        <i class="fa-solid fa-house me-1"></i> Về Trang Chủ
                    </a>
                </div>
            </div>
        </c:if>

        <!-- TRƯỜNG HỢP 2: CHƯA BẤM BIỂN -> GIAO DIỆN PHÒNG BẤM BIỂN -->
        <c:if test="${empty drawnPlate}">
            
            <c:choose>
                <%-- NẾU KHÔNG CÓ HỒ SƠ NÀO ĐƯỢC DUYỆT ĐỂ BẤM --%>
                <c:when test="${empty approvedRegistrations}">
                    <div class="card border-0 shadow-sm text-center py-5 px-3">
                        <i class="fa-solid fa-id-card fs-1 text-secondary opacity-50 mb-3"></i>
                        <h5 class="fw-bold text-dark mb-2">Hiện Tại Bạn Không Có Hồ Sơ Nào Chờ Bấm Biển Số</h5>
                        <p class="text-muted small mb-4" style="max-width: 500px; margin: 0 auto;">
                            Để bấm biển số, hồ sơ xe của bạn phải được Cán bộ CSGT thẩm định và chuyển sang trạng thái <strong>ĐÃ PHÊ DUYỆT (APPROVED)</strong> kèm mã dự thưởng (Draw Code).
                        </p>
                        <div class="d-flex justify-content-center gap-2">
                            <a href="${pageContext.request.contextPath}/user/dashboard" class="btn btn-outline-primary btn-sm px-4 fw-bold">
                                <i class="fa-solid fa-clock-rotate-left me-1"></i> Kiểm tra tiến độ hồ sơ
                            </a>
                            <a href="${pageContext.request.contextPath}/user/vehicle-form" class="btn btn-danger btn-sm px-4 fw-bold">
                                <i class="fa-solid fa-plus me-1"></i> Khai báo xe mới
                            </a>
                        </div>
                    </div>
                </c:when>

                <%-- NẾU CÓ HỒ SƠ ĐỦ ĐIỀU KIỆN --%>
                <c:otherwise>
                    <div class="card border-0 shadow-sm p-4 text-center mb-4">
                        
                        <div class="badge bg-danger text-white px-3 py-1 mb-2 mx-auto" style="font-size: 0.8rem;">
                            <i class="fa-solid fa-dice me-1"></i> PHÒNG BẤM BIỂN SỐ NGẪU NHIÊN TRỰC TUYẾN
                        </div>
                        <h4 class="fw-bold text-dark mb-1">Bốc Thăm Biển Số Định Danh Xe Máy</h4>
                        <p class="text-muted small mb-4">
                            Thuộc kho biển số: <strong>Công An <c:out value="${sessionScope.currentUser.district.districtName}" /></strong> &bull; Đầu biển: <strong class="text-danger"><c:out value="${sessionScope.currentUser.district.platePrefix}" /></strong>
                        </p>

                        <!-- BIỂN SỐ MÔ PHỎNG ĐANG CHỜ BẤM -->
                        <div class="license-plate-placeholder mb-4">
                            <div class="plate-prefix-row"><c:out value="${sessionScope.currentUser.district.platePrefix}" /></div>
                            <div class="plate-number-row" style="color: rgba(251, 224, 131, 0.4); letter-spacing: 6px;">???.??</div>
                        </div>

                        <!-- BIỂU MẪU CHỌN XE & NHẬP DRAW CODE (FORM POST THUẦN TÚY KHÔNG JS) -->
                        <form action="${pageContext.request.contextPath}/user/draw-plate" method="POST" style="max-width: 600px; margin: 0 auto;" class="text-start">
                            
                            <!-- 1. CHỌN HỒ SƠ XE CẦN BẤM -->
                            <div class="mb-3">
                                <label class="form-label fw-bold text-dark small">Chọn xe cần bấm biển số:</label>
                                <select name="registrationId" class="form-select form-select-lg fw-bold" required>
                                    <c:forEach var="reg" items="${approvedRegistrations}">
                                        <option value="${reg.registrationId}" <c:if test="${selectedRegistration.registrationId eq reg.registrationId}">selected</c:if>>
                                            Hồ sơ #${reg.registrationId}: ${reg.vehicle.brand.brandName} ${reg.vehicle.modelName} (Số khung: ${reg.vehicle.chassisNumber})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- 2. THÔNG TIN PHƯƠNG TIỆN ĐÃ CHỌN -->
                            <c:if test="${not empty selectedRegistration}">
                                <div class="p-3 bg-light rounded-3 border mb-3 small">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Phương tiện:</span>
                                        <strong><c:out value="${selectedRegistration.vehicle.brand.brandName}" /> &bull; <c:out value="${selectedRegistration.vehicle.modelName}" /></strong>
                                    </div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Số khung:</span>
                                        <code><c:out value="${selectedRegistration.vehicle.chassisNumber}" /></code>
                                    </div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span class="text-muted">Số máy:</span>
                                        <code><c:out value="${selectedRegistration.vehicle.engineNumber}" /></code>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span class="text-muted">Lệ phí đã nộp:</span>
                                        <strong class="text-success"><fmt:formatNumber value="${selectedRegistration.feeAmount}" type="number" maxFractionDigits="0" /> đ</strong>
                                    </div>
                                </div>
                            </c:if>

                            <!-- 3. NHẬP MÃ XÁC THỰC BẤM BIỂN (DRAW CODE - FR-05) -->
                            <div class="mb-4">
                                <label class="form-label fw-bold text-dark small">
                                    Mã dự thưởng do Cảnh sát giao thông cấp (Draw Code) <span class="text-danger">*</span>:
                                </label>
                                <div class="input-group input-group-lg">
                                    <span class="input-group-text bg-light text-muted"><i class="fa-solid fa-key"></i></span>
                                    <input type="text" 
                                           name="drawCode" 
                                           class="form-control font-monospace fw-bold text-uppercase" 
                                           placeholder="Ví dụ: DRAW-123456" 
                                           value="<c:out value='${selectedRegistration.drawCode}' />" 
                                           maxlength="50" 
                                           required>
                                </div>
                                <div class="form-text text-muted small">
                                    * Mã được ghi trong thông báo phê duyệt hồ sơ xe của bạn.
                                </div>
                            </div>

                            <!-- NÚT BẤM BIỂN SIÊU NỔI BẬT -->
                            <div class="text-center pt-2">
                                <button type="submit" class="btn btn-draw-plate w-100">
                                    <i class="fa-solid fa-dice me-2"></i> BẤM BIỂN SỐ NGẪU NHIÊN
                                </button>
                                <div class="text-muted small mt-2">
                                    <i class="fa-solid fa-shield-halved text-success me-1"></i> Thuật toán Atomic Draw đảm bảo 100% ngẫu nhiên, minh bạch và chống trùng lặp.
                                </div>
                            </div>

                        </form>

                    </div>
                </c:otherwise>
            </c:choose>

        </c:if>

    </main>

    <!-- FOOTER HỆ THỐNG -->
    <footer class="footer-vneid">
        <div class="container">
            <p class="mb-1 fw-bold text-dark">
                &copy; 2026 Cổng Dịch Vụ Công Đăng Ký & Bấm Biển Số Xe Máy Trực Tuyến
            </p>
            <p class="mb-0 text-muted">
                Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Chuẩn nhận diện định danh VNeID &bull; MVC2 Zero JS
            </p>
        </div>
    </footer>

</body>
</html>
