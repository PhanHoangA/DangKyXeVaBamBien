<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khai Báo Phương Tiện & Nộp Hồ Sơ Đăng Ký Mới - Chuẩn VNeID (FR-03)</title>
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

        /* Top Navbar Header VNeID */
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
            letter-spacing: 0.5px;
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

        /* Thẻ hồ sơ chủ xe */
        .citizen-summary-card {
            background: linear-gradient(135deg, #180304 0%, #3e070a 60%, #630c10 100%);
            border: 1.5px solid var(--vneid-gold);
            border-radius: 12px;
            color: #ffffff;
            padding: 20px 24px;
            box-shadow: 0 6px 20px rgba(122, 18, 20, 0.15);
            margin-bottom: 24px;
        }

        .section-header {
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 10px;
            margin-bottom: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            color: var(--vneid-red);
        }

        .form-card {
            background: #ffffff;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 24px;
        }

        .form-label {
            font-weight: 600;
            font-size: 0.88rem;
            color: #334155;
            margin-bottom: 6px;
        }

        .form-control, .form-select {
            border-radius: 8px;
            border: 1.5px solid #cbd5e1;
            padding: 10px 14px;
            font-size: 0.92rem;
            transition: all 0.2s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--vneid-red);
            box-shadow: 0 0 0 0.2rem rgba(168, 28, 30, 0.15);
        }

        .form-control.code-input {
            font-family: 'Montserrat', monospace;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .btn-vneid-primary {
            background: linear-gradient(135deg, #a81c1e 0%, #7a1214 100%);
            border: 1px solid var(--vneid-gold);
            color: #ffffff;
            font-weight: 700;
            padding: 12px 28px;
            border-radius: 8px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(122, 18, 20, 0.25);
        }

        .btn-vneid-primary:hover {
            background: linear-gradient(135deg, #bd2124 0%, #8f1517 100%);
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(122, 18, 20, 0.35);
        }

        .required-star {
            color: #dc2626;
            font-weight: bold;
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

    <!-- BẢO MẬT: BẮT BUỘC ĐĂNG NHẬP -->
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
                    <div>Cổng Dịch Vụ Công Đăng Ký Phương Tiện</div>
                    <div style="font-size: 0.72rem; color: var(--vneid-gold-light); font-weight: 500; text-transform: none; letter-spacing: 0;">
                        Bộ Công An &bull; Cục Cảnh Sát Giao Thông &bull; Đề Án 06/CP
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
    <main class="container my-4" style="max-width: 900px;">

        <!-- BREADCRUMB -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb small">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/home.jsp" class="text-danger text-decoration-none">Trang chủ</a></li>
                <li class="breadcrumb-item active" aria-current="page">Khai báo phương tiện mới (FR-03)</li>
            </ol>
        </nav>

        <!-- THÔNG BÁO LỖI NẾU CÓ (THUẦN JSTL) -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger border-0 shadow-sm d-flex align-items-center gap-2 mb-4">
                <i class="fa-solid fa-triangle-exclamation fs-4 text-danger"></i>
                <div class="fw-semibold"><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- THÔNG TIN CHỦ PHƯƠNG TIỆN & ĐỊA BÀN CẤP BIỂN (BR-01) -->
        <div class="citizen-summary-card">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-2">
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-warning text-dark fw-bold px-2 py-1" style="font-size: 0.72rem;">
                        <i class="fa-solid fa-id-card me-1"></i> ĐỊNH DANH ĐIỆN TỬ VNeID MỨC 2
                    </span>
                    <span class="text-white-50 small">&bull; Thông tin công dân tự động xác thực</span>
                </div>
                <div class="badge bg-danger text-white border border-light font-monospace">
                    Đầu biển ấn định: <c:out value="${sessionScope.currentUser.district.platePrefix}" />
                </div>
            </div>

            <div class="row g-3">
                <div class="col-md-4">
                    <div class="text-white-50 small">Họ và tên chủ xe:</div>
                    <div class="fw-bold fs-6 text-white"><c:out value="${sessionScope.currentUser.fullName}" /></div>
                </div>
                <div class="col-md-4">
                    <div class="text-white-50 small">Số Căn cước công dân (12 số):</div>
                    <div class="fw-bold fs-6 font-monospace text-warning"><c:out value="${sessionScope.currentUser.identityCard}" /></div>
                </div>
                <div class="col-md-4">
                    <div class="text-white-50 small">Số điện thoại liên hệ:</div>
                    <div class="fw-bold fs-6 text-white"><c:out value="${sessionScope.currentUser.phone}" /></div>
                </div>
                <div class="col-md-8">
                    <div class="text-white-50 small">Nơi đăng ký thường trú:</div>
                    <div class="text-white"><c:out value="${sessionScope.currentUser.address}" /></div>
                </div>
                <div class="col-md-4">
                    <div class="text-white-50 small">Cơ quan CSGT tiếp nhận thẩm định:</div>
                    <div class="text-warning fw-semibold">
                        Công An <c:out value="${sessionScope.currentUser.district.districtName}" /> - <c:out value="${sessionScope.currentUser.district.provinceName}" />
                    </div>
                </div>
            </div>
        </div>

        <!-- FORM KHAI BÁO PHƯƠNG TIỆN (FORM POST THUẦN TÚY KHÔNG JS) -->
        <form action="${pageContext.request.contextPath}/user/vehicle-form" method="POST">

            <!-- PHẦN 1: HÃNG XE VÀ DÒNG XE -->
            <div class="form-card">
                <div class="section-header">
                    <i class="fa-solid fa-motorcycle fs-5"></i>
                    <span>1. Thông Tin Hãng Sản Xuất & Loại Phương Tiện</span>
                </div>

                <div class="row g-3">
                    <!-- Hãng sản xuất -->
                    <div class="col-md-4">
                        <label class="form-label">Hãng sản xuất <span class="required-star">*</span></label>
                        <select name="brandId" class="form-select" required>
                            <option value="">-- Chọn hãng xe --</option>
                            <c:forEach var="b" items="${brands}">
                                <option value="${b.brandId}" <c:if test="${paramBrandId eq b.brandId}">selected</c:if>>
                                    <c:out value="${b.brandName}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Phân loại xe -->
                    <div class="col-md-4">
                        <label class="form-label">Phân loại xe máy <span class="required-star">*</span></label>
                        <select name="typeId" class="form-select" required>
                            <option value="">-- Chọn loại xe --</option>
                            <c:forEach var="t" items="${types}">
                                <option value="${t.typeId}" <c:if test="${paramTypeId eq t.typeId}">selected</c:if>>
                                    <c:out value="${t.typeName}" /> (<c:out value="${t.capacityRange}" />)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Tên thương mại dòng xe -->
                    <div class="col-md-4">
                        <label class="form-label">Tên thương mại dòng xe <span class="required-star">*</span></label>
                        <input type="text" 
                               name="modelName" 
                               class="form-control" 
                               placeholder="Ví dụ: SH 150i, Vision, Exciter 155..." 
                               value="<c:out value='${paramModelName}' />" 
                               maxlength="50" 
                               required>
                    </div>
                </div>
            </div>

            <!-- PHẦN 2: THÔNG SỐ KỸ THUẬT & ĐỊNH DANH XE (BR-02 & BR-05) -->
            <div class="form-card">
                <div class="section-header">
                    <i class="fa-solid fa-microchip fs-5"></i>
                    <span>2. Thông Số Kỹ Thuật Phương Tiện (Định Danh Duy Nhất)</span>
                </div>

                <div class="alert alert-info border-0 py-2 small d-flex align-items-center gap-2 mb-3">
                    <i class="fa-solid fa-circle-info text-primary fs-5"></i>
                    <div>
                        <strong>Lưu ý quan trọng (BR-02):</strong> Số máy và Số khung của xe phải trùng khớp tuyệt đối với Phiếu kiểm tra chất lượng xuất xưởng. Hệ thống sẽ từ chối nếu số khung/số máy đã tồn tại.
                    </div>
                </div>

                <div class="row g-3">
                    <!-- Số khung -->
                    <div class="col-md-6">
                        <label class="form-label">Số khung (Chassis Number) <span class="required-star">*</span></label>
                        <input type="text" 
                               name="chassisNumber" 
                               class="form-control code-input" 
                               placeholder="Ví dụ: RLHJF5109KY123456" 
                               value="<c:out value='${paramChassisNumber}' />" 
                               maxlength="50" 
                               required>
                        <div class="form-text text-muted small">Khắc trên cổ xe hoặc dưới yên xe (chữ hoa và số).</div>
                    </div>

                    <!-- Số máy -->
                    <div class="col-md-6">
                        <label class="form-label">Số máy (Engine Number) <span class="required-star">*</span></label>
                        <input type="text" 
                               name="engineNumber" 
                               class="form-control code-input" 
                               placeholder="Ví dụ: JF51E0123456" 
                               value="<c:out value='${paramEngineNumber}' />" 
                               maxlength="50" 
                               required>
                        <div class="form-text text-muted small">Khắc tại lốc máy động cơ phương tiện.</div>
                    </div>

                    <!-- Màu sơn -->
                    <div class="col-md-6">
                        <label class="form-label">Màu sơn xe <span class="required-star">*</span></label>
                        <input type="text" 
                               name="color" 
                               class="form-control" 
                               placeholder="Ví dụ: Đen nhám, Đỏ đen, Trắng..." 
                               value="<c:out value='${paramColor}' />" 
                               maxlength="50" 
                               required>
                    </div>

                    <!-- Dung tích xi-lanh -->
                    <div class="col-md-6">
                        <label class="form-label">Dung tích xi-lanh (cm³) <span class="required-star">*</span></label>
                        <div class="input-group">
                            <input type="number" 
                                   name="engineCapacity" 
                                   class="form-control font-monospace" 
                                   placeholder="Ví dụ: 125, 150 (Nhập 0 nếu là xe máy điện)" 
                                   value="<c:out value='${paramEngineCapacity}' default='125' />" 
                                   min="0" 
                                   max="2000" 
                                   required>
                            <span class="input-group-text bg-light text-muted">cm³ (cc)</span>
                        </div>
                        <div class="form-text text-muted small">Quy tắc BR-05: Dung tích &ge; 0 (Bằng 0 đối với xe máy điện).</div>
                    </div>
                </div>
            </div>

            <!-- PHẦN 3: HỒ SƠ TÀI CHÍNH & THUẾ TRƯỚC BẠ -->
            <div class="form-card">
                <div class="section-header">
                    <i class="fa-solid fa-file-invoice-dollar fs-5"></i>
                    <span>3. Chứng Từ Thuế Trước Bạ & Hóa Đơn Mua Xe</span>
                </div>

                <div class="row g-3">
                    <!-- Giá trị xe -->
                    <div class="col-md-4">
                        <label class="form-label">Giá trị xe trên hóa đơn (VNĐ) <span class="required-star">*</span></label>
                        <div class="input-group">
                            <input type="number" 
                                   name="vehicleValue" 
                                   class="form-control font-monospace fw-bold text-success" 
                                   placeholder="Ví dụ: 35000000" 
                                   value="<c:out value='${paramVehicleValue}' default='35000000' />" 
                                   min="1000000" 
                                   step="500000" 
                                   required>
                            <span class="input-group-text bg-light text-muted">VNĐ</span>
                        </div>
                        <div class="form-text text-muted small">Quy tắc BR-05: Giá trị xe phải lớn hơn 0 VNĐ.</div>
                    </div>

                    <!-- Số biên lai thuế trước bạ -->
                    <div class="col-md-4">
                        <label class="form-label">Số biên lai thuế trước bạ <span class="required-star">*</span></label>
                        <input type="text" 
                               name="taxReceiptNumber" 
                               class="form-control code-input" 
                               placeholder="Ví dụ: BL-2026-998811" 
                               value="<c:out value='${paramTaxReceiptNumber}' />" 
                               maxlength="50" 
                               required>
                        <div class="form-text text-muted small">Số chứng từ nộp thuế trên Cổng Dịch vụ công.</div>
                    </div>

                    <!-- Số hóa đơn GTGT/VAT -->
                    <div class="col-md-4">
                        <label class="form-label">Số hóa đơn VAT mua xe <span class="required-star">*</span></label>
                        <input type="text" 
                               name="invoiceNumber" 
                               class="form-control code-input" 
                               placeholder="Ví dụ: HD-VAT-001293" 
                               value="<c:out value='${paramInvoiceNumber}' />" 
                               maxlength="50" 
                               required>
                        <div class="form-text text-muted small">Hóa đơn điện tử xuất từ đại lý xe máy.</div>
                    </div>
                </div>
            </div>

            <!-- PHẦN 4: CAM ĐOAN VÀ NỘP HỒ SƠ -->
            <div class="form-card bg-light border">
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="agreementCheck" required checked>
                    <label class="form-check-label small" for="agreementCheck">
                        Tôi xin cam đoan toàn bộ thông tin phương tiện, số khung, số máy và hóa đơn nêu trên là hoàn toàn chính xác. Nếu sai lệch, tôi xin chịu hoàn toàn trách nhiệm trước pháp luật về đăng ký phương tiện giao thông đường bộ.
                    </label>
                </div>

                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 pt-2">
                    <a href="${pageContext.request.contextPath}/home.jsp" class="btn btn-outline-secondary px-4 fw-medium">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                    </a>

                    <button type="submit" class="btn btn-vneid-primary px-4 py-2.5">
                        <i class="fa-solid fa-paper-plane me-2 text-warning"></i> Nộp Hồ Sơ Đăng Ký Phương Tiện
                    </button>
                </div>
            </div>

        </form>

    </main>

    <!-- FOOTER HỆ THỐNG -->
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
