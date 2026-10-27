<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Ký Tài Khoản Định Danh Công Dân | Hệ Thống Bấm Biển Số Xe Máy</title>
    
    <!-- Google Fonts & FontAwesome 6 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&family=Montserrat:wght@600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --vneid-red: #a81c1e;
            --vneid-red-dark: #7a1214;
            --vneid-red-deep: #540809;
            --vneid-gold: #e5a919;
            --vneid-gold-light: #fbe083;
            --vneid-gold-dark: #9e7107;
            --card-bg: #ffffff;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --border-light: #e2e8f0;
            --input-bg: #f8fafc;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Be Vietnam Pro', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #480607 0%, #7a1214 45%, #961619 75%, #5a090b 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 15px;
            color: var(--text-dark);
            position: relative;
            overflow-x: hidden;
        }

        /* Nền mờ họa tiết Trống Đồng & Hiệu ứng phát sáng */
        .trong-dong-bg {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 1000px;
            height: 1000px;
            border-radius: 50%;
            border: 2px dashed rgba(241, 181, 28, 0.12);
            pointer-events: none;
            z-index: 0;
        }

        .trong-dong-bg::before {
            content: "";
            position: absolute;
            inset: 60px;
            border-radius: 50%;
            border: 1px solid rgba(241, 181, 28, 0.08);
        }

        .glow-sphere {
            position: fixed;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(229, 169, 25, 0.15) 0%, rgba(122, 18, 20, 0) 70%);
            top: -100px;
            right: -100px;
            border-radius: 50%;
            pointer-events: none;
            z-index: 0;
        }

        .glow-sphere-2 {
            position: fixed;
            width: 450px;
            height: 450px;
            background: radial-gradient(circle, rgba(251, 224, 131, 0.12) 0%, rgba(122, 18, 20, 0) 70%);
            bottom: -80px;
            left: -80px;
            border-radius: 50%;
            pointer-events: none;
            z-index: 0;
        }

        .main-wrapper {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 1100px;
        }

        /* Header Cổng Dịch Vụ */
        .portal-header {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 16px;
            text-align: center;
            margin-bottom: 24px;
            color: #fff;
        }

        .emblem-wrapper {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: radial-gradient(circle, #fff3c4 0%, #e5a919 70%, #996500 100%);
            box-shadow: 0 0 25px rgba(229, 169, 25, 0.6);
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid #fffae6;
            flex-shrink: 0;
        }

        .emblem-wrapper i {
            font-size: 32px;
            color: var(--vneid-red);
        }

        .portal-title-block h4 {
            font-size: 0.9rem;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--vneid-gold-light);
            font-weight: 700;
            margin-bottom: 4px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.5);
        }

        .portal-title-block h1 {
            font-size: 1.45rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            text-shadow: 0 2px 8px rgba(0,0,0,0.4);
            margin: 0;
        }

        .portal-subtitle {
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.85);
            margin-top: 3px;
        }

        /* Khối Container Card Split */
        .register-container {
            background: #ffffff;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.45);
            display: flex;
            border: 1px solid rgba(251, 224, 131, 0.35);
        }

        /* Cột trái: Hướng dẫn định danh VNeID */
        .info-panel {
            flex: 0 0 350px;
            background: linear-gradient(165deg, #7a1214 0%, #560b0d 60%, #3e0405 100%);
            color: #ffffff;
            padding: 36px 30px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            border-right: 1px solid rgba(241, 181, 28, 0.25);
        }

        .info-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: rgba(229, 169, 25, 0.18);
            border: 1px solid rgba(229, 169, 25, 0.4);
            border-radius: 30px;
            color: var(--vneid-gold-light);
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.8px;
            text-transform: uppercase;
            margin-bottom: 20px;
        }

        .info-panel h3 {
            font-size: 1.35rem;
            font-weight: 800;
            line-height: 1.35;
            color: #ffffff;
            margin-bottom: 14px;
        }

        .info-panel p {
            font-size: 0.88rem;
            color: rgba(255, 255, 255, 0.85);
            line-height: 1.6;
            margin-bottom: 24px;
        }

        .notice-card {
            background: rgba(255, 255, 255, 0.08);
            border: 1px dashed rgba(251, 224, 131, 0.4);
            border-radius: 12px;
            padding: 16px;
            margin-bottom: 20px;
        }

        .notice-card h5 {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--vneid-gold-light);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .notice-card ul {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.82);
            line-height: 1.5;
        }

        .notice-card li {
            position: relative;
            padding-left: 18px;
            margin-bottom: 8px;
        }

        .notice-card li:last-child {
            margin-bottom: 0;
        }

        .notice-card li::before {
            content: "✓";
            position: absolute;
            left: 0;
            color: var(--vneid-gold-light);
            font-weight: bold;
        }

        .vneid-chip-box {
            background: linear-gradient(135deg, rgba(255,255,255,0.12) 0%, rgba(255,255,255,0.03) 100%);
            border: 1px solid rgba(251, 224, 131, 0.3);
            border-radius: 12px;
            padding: 14px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .vneid-chip-box .chip-icon {
            width: 36px;
            height: 26px;
            background: linear-gradient(135deg, #fce084 0%, #d4af37 100%);
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #5c3f00;
            font-size: 12px;
            flex-shrink: 0;
        }

        .vneid-chip-box .chip-text {
            font-size: 0.78rem;
            color: rgba(255, 255, 255, 0.9);
            line-height: 1.35;
        }

        /* Cột phải: Form Đăng Ký */
        .form-panel {
            flex: 1;
            padding: 40px 42px;
            background: #ffffff;
        }

        .form-header {
            margin-bottom: 24px;
            border-bottom: 1px solid var(--border-light);
            padding-bottom: 14px;
        }

        .form-header h2 {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--vneid-red-dark);
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-header p {
            font-size: 0.88rem;
            color: var(--text-muted);
            margin: 0;
        }

        /* Section Title trong Form */
        .section-label {
            font-size: 0.82rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--vneid-red);
            background: rgba(168, 28, 30, 0.06);
            padding: 4px 10px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-bottom: 16px;
        }

        /* Input Controls */
        .form-group-custom {
            margin-bottom: 18px;
        }

        .form-group-custom label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .form-group-custom label .required-star {
            color: #dc2626;
            margin-left: 2px;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 14px;
            pointer-events: none;
            transition: color 0.2s;
        }

        .form-control-custom, .form-select-custom {
            width: 100%;
            height: 45px;
            background-color: var(--input-bg);
            border: 1.5px solid var(--border-light);
            border-radius: 8px;
            padding: 0 14px 0 40px;
            font-size: 0.92rem;
            color: var(--text-dark);
            transition: all 0.2s ease;
        }

        .form-control-custom:focus, .form-select-custom:focus {
            outline: none;
            border-color: var(--vneid-red);
            background-color: #ffffff;
            box-shadow: 0 0 0 3px rgba(168, 28, 30, 0.12);
        }

        .form-group-custom .field-hint {
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-top: 4px;
        }

        /* Alert Lỗi thuần JSTL */
        .alert-danger-custom {
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 22px;
            font-size: 0.88rem;
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 4px solid #dc2626;
            background: #fef2f2;
            color: #991b1b;
        }

        /* Nút Đăng Ký */
        .btn-vneid-submit {
            width: 100%;
            height: 50px;
            background: linear-gradient(135deg, #c92a2a 0%, #a81c1e 50%, #7a1214 100%);
            border: none;
            border-radius: 10px;
            color: #ffffff;
            font-size: 1rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(168, 28, 30, 0.3);
            margin-top: 10px;
        }

        .btn-vneid-submit:hover {
            background: linear-gradient(135deg, #d93838 0%, #ba1b1d 50%, #8c1417 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(168, 28, 30, 0.4);
            color: #ffffff;
        }

        /* Link Điều Hướng Dưới Form */
        .form-footer-links {
            text-align: center;
            margin-top: 22px;
            padding-top: 18px;
            border-top: 1px solid var(--border-light);
            font-size: 0.9rem;
            color: var(--text-muted);
        }

        .form-footer-links a {
            color: var(--vneid-red);
            font-weight: 700;
            text-decoration: none;
            margin-left: 4px;
        }

        .form-footer-links a:hover {
            text-decoration: underline;
        }

        .back-home-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            margin-bottom: 16px;
            transition: color 0.2s;
        }

        .back-home-link:hover {
            color: var(--vneid-gold-light);
        }

        /* Footer Bản Quyền */
        .system-footer {
            text-align: center;
            color: rgba(255, 255, 255, 0.75);
            font-size: 0.8rem;
            margin-top: 24px;
        }

        .system-footer a {
            color: var(--vneid-gold-light);
            text-decoration: none;
        }

        /* Responsive Breakpoints */
        @media (max-width: 960px) {
            .register-container {
                flex-direction: column;
            }
            .info-panel {
                flex: 1 1 100%;
                border-right: none;
                border-bottom: 1px solid rgba(241, 181, 28, 0.25);
                padding: 28px 24px;
            }
            .form-panel {
                padding: 30px 24px;
            }
            .portal-title-block h1 {
                font-size: 1.2rem;
            }
            .emblem-wrapper {
                width: 52px;
                height: 52px;
            }
            .emblem-wrapper i {
                font-size: 26px;
            }
        }
    </style>
</head>
<body>

    <!-- Nền mờ hoa văn Trống Đồng & Vòng cầu sáng -->
    <div class="trong-dong-bg"></div>
    <div class="glow-sphere"></div>
    <div class="glow-sphere-2"></div>

    <div class="main-wrapper">
        
        <!-- Nút Trở Về Trang Chủ -->
        <a href="${pageContext.request.contextPath}/home.jsp" class="back-home-link">
            <i class="fa-solid fa-arrow-left"></i> Quay lại Cổng thông tin trang chủ
        </a>

        <!-- HEADER CỔNG DỊCH VỤ -->
        <header class="portal-header">
            <div class="emblem-wrapper">
                <i class="fa-solid fa-shield-halved"></i>
            </div>
            <div class="portal-title-block text-start">
                <h4>Bộ Công An &bull; Cục Cảnh Sát Giao Thông</h4>
                <h1>Hệ Thống Đăng Ký & Bấm Biển Số Xe Trực Tuyến</h1>
                <div class="portal-subtitle">Cổng đăng ký tài khoản công dân phục vụ thủ tục phương tiện</div>
            </div>
        </header>

        <!-- CONTAINER CHÍNH -->
        <div class="register-container">
            
            <!-- CỘT TRÁI: HƯỚNG DẪN ĐỊNH DANH & BẢO MẬT VNeID -->
            <div class="info-panel">
                <div>
                    <div class="info-badge">
                        <i class="fa-solid fa-circle-check"></i> ĐỊNH DANH ĐIỆN TỬ
                    </div>
                    <h3>Tài Khoản Công Dân Đăng Ký Xe Trực Tuyến</h3>
                    <p>
                        Hệ thống kết nối cơ sở dữ liệu quốc gia về dân cư. Công dân sử dụng số định danh cá nhân (CCCD 12 số) để nộp hồ sơ đăng ký xe và bấm biển số ngẫu nhiên trực tuyến.
                    </p>

                    <div class="notice-card">
                        <h5><i class="fa-solid fa-circle-info"></i> Quy Định Bắt Buộc</h5>
                        <ul>
                            <li><strong>Số CCCD:</strong> Đúng chuẩn 12 chữ số theo Căn cước công dân gắn chip.</li>
                            <li><strong>Quận/Huyện thường trú:</strong> Biển số xe mô tô sẽ được hệ thống tự động cấp theo đầu số mã vùng của Quận/Huyện này.</li>
                            <li><strong>Duy nhất:</strong> Mỗi công dân (CCCD) và mỗi tên đăng nhập chỉ được tạo 01 tài khoản.</li>
                        </ul>
                    </div>
                </div>

                <div class="vneid-chip-box">
                    <div class="chip-icon">
                        <i class="fa-solid fa-microchip"></i>
                    </div>
                    <div class="chip-text">
                        <strong>Xác thực an toàn cấp độ 3</strong><br>
                        Thông tin được bảo vệ và mã hóa theo tiêu chuẩn an toàn dữ liệu của Bộ Công An.
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: FORM ĐĂNG KÝ THUẦN JSP/JSTL (KHÔNG DÙNG JAVASCRIPT) -->
            <div class="form-panel">
                
                <div class="form-header">
                    <h2>
                        <i class="fa-solid fa-user-plus"></i> Đăng Ký Tài Khoản Công Dân
                    </h2>
                    <p>Vui lòng điền thông tin chính xác theo giấy Căn cước công dân</p>
                </div>

                <!-- Thông báo lỗi hiển thị thuần JSTL từ Servlet -->
                <c:if test="${not empty error}">
                    <div class="alert-danger-custom">
                        <i class="fa-solid fa-circle-exclamation fs-5 flex-shrink-0"></i>
                        <span><c:out value="${error}" /></span>
                    </div>
                </c:if>

                <!-- FORM ĐĂNG KÝ SUBMIT VỀ SERVLET /register -->
                <form action="${pageContext.request.contextPath}/register" method="POST">
                    
                    <!-- PHẦN 1: THÔNG TIN TÀI KHOẢN -->
                    <div class="section-label">
                        <i class="fa-solid fa-key"></i> 1. Thông Tin Tài Khoản Đăng Nhập
                    </div>

                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group-custom">
                                <label for="userName">Tên đăng nhập <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-regular fa-user input-icon"></i>
                                    <input type="text" 
                                           id="userName" 
                                           name="userName" 
                                           class="form-control-custom" 
                                           value="<c:out value="${userName}" />"
                                           placeholder="Ví dụ: nguyen_van_a hoặc số CCCD" 
                                           maxlength="50" 
                                           required 
                                           autocomplete="username">
                                </div>
                                <div class="field-hint">Tên dùng để đăng nhập hệ thống cùng mật khẩu.</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="userpassword">Mật khẩu <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-lock input-icon"></i>
                                    <input type="password" 
                                           id="userpassword" 
                                           name="userpassword" 
                                           class="form-control-custom" 
                                           placeholder="Tối thiểu 6 ký tự" 
                                           minlength="6" 
                                           required 
                                           autocomplete="new-password">
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="confirmPassword">Xác nhận mật khẩu <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-shield-halved input-icon"></i>
                                    <input type="password" 
                                           id="confirmPassword" 
                                           name="confirmPassword" 
                                           class="form-control-custom" 
                                           placeholder="Nhập lại mật khẩu" 
                                           minlength="6" 
                                           required 
                                           autocomplete="new-password">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- PHẦN 2: THÔNG TIN ĐỊNH DANH CÔNG DÂN -->
                    <div class="section-label mt-2">
                        <i class="fa-solid fa-address-card"></i> 2. Thông Tin Định Danh & Cư Trú
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="fullName">Họ và tên đầy đủ <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-id-badge input-icon"></i>
                                    <input type="text" 
                                           id="fullName" 
                                           name="fullName" 
                                           class="form-control-custom" 
                                           value="<c:out value="${fullName}" />"
                                           placeholder="Ví dụ: NGUYỄN VĂN A" 
                                           maxlength="100" 
                                           required>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="identityCard">Số CCCD / Định danh (12 số) <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-fingerprint input-icon"></i>
                                    <input type="text" 
                                           id="identityCard" 
                                           name="identityCard" 
                                           class="form-control-custom" 
                                           value="<c:out value="${identityCard}" />"
                                           placeholder="001202000001" 
                                           maxlength="12" 
                                           pattern="[0-9]{12}" 
                                           title="Vui lòng nhập đúng 12 chữ số Căn cước công dân"
                                           required>
                                </div>
                                <div class="field-hint">Số CCCD phải gồm đúng 12 chữ số.</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="phone">Số điện thoại liên hệ <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-phone input-icon"></i>
                                    <input type="tel" 
                                           id="phone" 
                                           name="phone" 
                                           class="form-control-custom" 
                                           value="<c:out value="${phone}" />"
                                           placeholder="0912345678" 
                                           maxlength="11" 
                                           pattern="[0-9]{10,11}" 
                                           title="Số điện thoại từ 10 đến 11 chữ số"
                                           required>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="form-group-custom">
                                <label for="email">Địa chỉ Email (Thư điện tử)</label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-envelope input-icon"></i>
                                    <input type="email" 
                                           id="email" 
                                           name="email" 
                                           class="form-control-custom" 
                                           value="<c:out value="${email}" />"
                                           placeholder="example@gmail.com" 
                                           maxlength="100">
                                </div>
                                <div class="field-hint">Dùng để nhận thông báo duyệt hồ sơ và mã bấm biển.</div>
                            </div>
                        </div>

                        <div class="col-md-12">
                            <div class="form-group-custom">
                                <label for="districtId">Quận / Huyện Thường Trú (Nơi cấp biển số xe) <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-location-dot input-icon"></i>
                                    <select id="districtId" name="districtId" class="form-select-custom" required>
                                        <option value="">-- Chọn Quận/Huyện thường trú theo CCCD --</option>
                                        <c:forEach items="${districtList}" var="d">
                                            <option value="${d.districtId}" ${d.districtId == selectedDistrictId ? 'selected' : ''}>
                                                <c:out value="${d.districtName}" /> - <c:out value="${d.provinceName}" /> (Ký hiệu biển: <c:out value="${d.platePrefix}" />)
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="field-hint text-danger fw-semibold">
                                    * Lưu ý quan trọng: Biển số xe sẽ được cấp theo đầu số Quận/Huyện được chọn tại đây.
                                </div>
                            </div>
                        </div>

                        <div class="col-md-12">
                            <div class="form-group-custom">
                                <label for="address">Địa chỉ thường trú chi tiết <span class="required-star">*</span></label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-house-chimney input-icon"></i>
                                    <input type="text" 
                                           id="address" 
                                           name="address" 
                                           class="form-control-custom" 
                                           value="<c:out value="${address}" />"
                                           placeholder="Số nhà, tên ngõ/phố, Phường/Xã..." 
                                           maxlength="255" 
                                           required>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- NÚT GỬI ĐĂNG KÝ -->
                    <button type="submit" class="btn-vneid-submit">
                        <i class="fa-solid fa-user-check"></i> HOÀN TẤT ĐĂNG KÝ TÀI KHOẢN
                    </button>
                </form>

                <!-- LINK ĐĂNG NHẬP -->
                <div class="form-footer-links">
                    Đã có tài khoản trên hệ thống? 
                    <a href="${pageContext.request.contextPath}/login">
                        <i class="fa-solid fa-right-to-bracket me-1"></i>Đăng nhập ngay
                    </a>
                </div>

            </div>

        </div>

        <!-- FOOTER BẢN QUYỀN -->
        <footer class="system-footer">
            <p class="mb-1">&copy; 2026 Cổng Dịch Vụ Công Đăng Ký Phương Tiện & Bấm Biển Số Xe Máy Trực Tuyến.</p>
            <p class="mb-0">
                Tuân thủ quy chuẩn định danh điện tử <a href="#">VNeID</a> &bull; Bảo mật theo tiêu chuẩn an toàn thông tin cấp độ 3.
            </p>
        </footer>

    </div>

</body>
</html>
