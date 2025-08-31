
USE QuanLyEvoucher;

-- Thêm dữ liệu vào bảng [app].[Org] 
INSERT INTO [app].[Org] (App_Org_Id, CreateUser, CreateDate, IsActive, Code, Name, NameEn, Type_Id, Address, Description, ParentId, DisplayOrder) VALUES
('org1', 'system', GETDATE(), 1, 'CTY_A', N'Công ty A', 'Company A', NULL, N'Hà Nội', N'Công ty Cổ phần A', NULL, 1),
('org2', 'system', GETDATE(), 1, 'CN_A1', N'Chi nhánh A1', 'Branch A1', NULL, N'TP. Hồ Chí Minh', N'Chi nhánh của Công ty A', 'org1', 1),
('org3', 'system', GETDATE(), 1, 'PB_HR', N'Phòng ban HR', 'HR Department', NULL, N'Hà Nội', N'Phòng ban nhân sự', 'org1', 1);

-- Thêm dữ liệu vào bảng [app].[Dic_Domain] 
INSERT INTO [app].[Dic_Domain] (App_Dic_Domain_Id, CreateUser, CreateDate, IsActive, App_Org_Id, DomainCode, ItemCode, ItemValue, DisplayOrder, Description) VALUES
('dd1', 'system', GETDATE(), 1, 'org1', 'ORG_TYPE', 'COMPANY', N'Công ty', 1, N'Loại tổ chức: Công ty'),
('dd2', 'system', GETDATE(), 1, 'org1', 'ORG_TYPE', 'BRANCH', N'Chi nhánh', 2, N'Loại tổ chức: Chi nhánh'),
('dd3', 'system', GETDATE(), 1, 'org1', 'ORG_TYPE', 'DEPARTMENT', N'Phòng ban', 3, N'Loại tổ chức: Phòng ban');

-- Thêm dữ liệu vào bảng [app].[Permission] 
INSERT INTO [app].[Permission] (Permission_Id, Code, Name, Description) VALUES
('p1', 'VIEW_MENU', N'Xem Menu', N'Quyền xem menu chức năng'),
('p2', 'MANAGE_USER', N'Quản lý người dùng', N'Quyền thêm/sửa/xóa người dùng'),
('p3', 'DISTRIBUTE_VOUCHER', N'Phân phối Voucher', N'Quyền phân phối voucher cho nhân viên'),
('p4', 'VIEW_VOUCHER_OWN', N'Xem Voucher của mình', N'Quyền xem các voucher cá nhân');

-- Thêm dữ liệu vào bảng [app].[User] 
INSERT INTO [app].[User] (App_User_Id, CreateUser, CreateDate, IsActive, App_Org_Id, UserName, FullName, Email, EmailConfirmed, PhoneNumber, PhoneNumberConfirmed, AccessFailedCount, IsAdmin, PasswordHash, LastLogin) VALUES
('user1', 'system', GETDATE(), 1, 'org1', 'admin_A', N'Nguyễn Văn A', 'admin.a@ctya.vn', 1, '0987654321', 1, 0, 1, 'hashed_password_1', GETDATE()),
('user2', 'system', GETDATE(), 1, 'org3', 'hr_B', N'Trần Thị B', 'hr.b@ctya.vn', 1, '0912345678', 1, 0, 0, 'hashed_password_2', GETDATE()),
('user3', 'system', GETDATE(), 1, 'org1', 'emp_C', N'Lê Văn C', 'emp.c@ctya.vn', 1, '0900000000', 1, 0, 0, 'hashed_password_3', GETDATE());

-- Thêm dữ liệu vào bảng [app].[Menu] 
INSERT INTO [app].[Menu] (App_Menu_Id, CreateUser, CreateDate, IsActive, App_Org_Id, Name, TranslateKey, Url, Icon, DisplayOrder, ParentId) VALUES
('menu1', 'system', GETDATE(), 1, 'org1', N'Trang chủ', 'menu.home', '/', 'home', 1, NULL),
('menu2', 'system', GETDATE(), 1, 'org1', N'Quản lý E-Voucher', 'menu.evoucher', '/evoucher-management', 'evoucher', 2, NULL),
('menu3', 'system', GETDATE(), 1, 'org1', N'Phân phối Voucher', 'menu.distribute_voucher', '/evoucher-management/distribute', 'distribute', 3, 'menu2'),
('menu4', 'system', GETDATE(), 1, 'org1', N'Voucher của tôi', 'menu.my_voucher', '/my-vouchers', 'my-vouchers', 4, NULL),
('menu5', 'system', GETDATE(), 1, 'org1', N'Quản lý người dùng', 'menu.user_management', '/user-management', 'user', 5, NULL),
('menu6', 'system', GETDATE(), 1, 'org1', N'Quản lý danh mục', 'menu.category_management', '/category-management', 'category', 6, NULL),
('menu7', 'system', GETDATE(), 1, 'org1', N'Cấu hình hệ thống', 'menu.system_setting', '/system-setting', 'setting', 7, NULL);

-- Thêm dữ liệu vào bảng [app].[Role] 
INSERT INTO [app].[Role] (App_Role_Id, CreateUser, CreateDate, IsActive, App_Org_Id, Code, Name, Description) VALUES
('role_admin', 'system', GETDATE(), 1, 'org1', 'ADMIN', N'Quản trị viên', N'Quản lý toàn bộ hệ thống'),
('role_hr', 'system', GETDATE(), 1, 'org1', 'HR', N'Nhân sự', N'Quản lý phân phối voucher'),
('role_employee', 'system', GETDATE(), 1, 'org1', 'EMPLOYEE', N'Nhân viên', N'Nhận và sử dụng voucher');

-- Thêm dữ liệu vào bảng [app].[Setting] 
INSERT INTO [app].[Setting] (App_Setting_Id, CreateUser, CreateDate, IsActive, App_Org_Id, Code, Value, Description) VALUES
('s1', 'system', GETDATE(), 1, 'org1', 'VOUCHER_EXPIRY_MONTHS', '6', N'Thời gian hết hạn voucher (tính bằng tháng)'),
('s2', 'system', GETDATE(), 1, 'org1', 'DEFAULT_VOUCHER_VALUE', '50000', N'Giá trị voucher mặc định');

-- Thêm dữ liệu vào bảng [app].[Sequence] 
INSERT INTO [app].[Sequence] (App_Sequence_Id, CreateUser, CreateDate, IsActive, App_Org_Id, Code, Type_Id, Prefix, Length, SeqValue, Description) VALUES
('seq1', 'system', GETDATE(), 1, 'org1', 'VOUCHER_CODE', NULL, 'VC', 10, 1, N'Sinh mã code voucher tự động');

-- Thêm dữ liệu vào bảng [app].[UserSession] 
INSERT INTO [app].[UserSession] (Session_Id, App_User_Id, Token, ExpireAt, IsActive) VALUES
('session1', 'user1', 'token_admin', DATEADD(hour, 1, GETDATE()), 1),
('session2', 'user2', 'token_hr', DATEADD(hour, 1, GETDATE()), 1),
('session3', 'user3', 'token_employee', DATEADD(hour, 1, GETDATE()), 1);

--  Role – Permission
INSERT INTO [app].[Role_Permission_Ref] (Role_Permission_Ref_Id, App_Role_Id, Permission_Id) VALUES
('rp1', 'role_admin', 'p1'),
('rp2', 'role_admin', 'p2'),
('rp3', 'role_admin', 'p3'),
('rp4', 'role_admin', 'p4'),
('rp5', 'role_hr', 'p1'),
('rp6', 'role_hr', 'p3'),
('rp7', 'role_employee', 'p1'),
('rp8', 'role_employee', 'p4');

-- Role – Menu
INSERT INTO [app].[Role_Menu_Ref] (App_Role_Menu_Ref_Id, CreateUser, CreateDate, App_Role_Id, App_Menu_Id) VALUES
('rm1', 'system', GETDATE(), 'role_admin', 'menu1'),
('rm2', 'system', GETDATE(), 'role_admin', 'menu2'),
('rm3', 'system', GETDATE(), 'role_admin', 'menu5'),
('rm4', 'system', GETDATE(), 'role_admin', 'menu6'),
('rm5', 'system', GETDATE(), 'role_admin', 'menu7'),
('rm6', 'system', GETDATE(), 'role_hr', 'menu1'),
('rm7', 'system', GETDATE(), 'role_hr', 'menu2'),
('rm8', 'system', GETDATE(), 'role_hr', 'menu3'),
('rm9', 'system', GETDATE(), 'role_employee', 'menu1'),
('rm10', 'system', GETDATE(), 'role_employee', 'menu4');

-- User – Org
INSERT INTO [app].[User_Org_Ref] (App_User_Org_Ref_Id, CreateUser, CreateDate, App_User_Id, App_Org_Id) VALUES
('uo1', 'system', GETDATE(), 'user1', 'org1'),
('uo2', 'system', GETDATE(), 'user2', 'org3'),
-- User – Role
INSERT INTO [app].[User_Role_Ref] (App_User_Role_Ref_Id, CreateUser, CreateDate, App_User_Id, App_Role_Id) VALUES
('ur1', 'system', GETDATE(), 'user1', 'role_admin'),
('ur2', 'system', GETDATE(), 'user2', 'role_hr'),
('ur3', 'system', GETDATE(), 'user3', 'role_employee');