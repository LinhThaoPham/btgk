
USE QuanLyEvoucher;
--. Viết procedure 
-- Phân bổ voucher theo loại, số lượng(tạo ra nhiều voucher cùng loại, số lượng, giá trị và thời gian hiệu lực).
--Gán mã voucher cụ thể cho nhân viên.
-- Đánh dấu voucher đã sử dụng, cập nhật useddate + usedby.
-- Gia hạn validto.
-- Thu hồi voucher chưa dùng.
-- Báo cáo số lượng + giá trị 

-- @ReleaseDate = '2025-08-31';
GO
CREATE PROCEDURE voucher.GenarateVoucher 
(
	@VoucherID     VARCHAR(100) = NULL ,
	@Quantity        INT = 0,
    @ValidBegin    DATE = NULL, 
    @ValidEnd      DATE = NULL, 
    @ReleaseDate   DATE = NULL
)
AS
	BEGIN 
		SET NOCOUNT ON;
		DECLARE @prefix VARCHAR(10);
		IF @VoucherID = 'VC100' SET @Prefix = 'BAD';
		IF @VoucherID = 'VC200' SET @Prefix = 'CBD';
		IF @VoucherID = 'CC4' SET @Prefix = 'ACC';

		DECLARE @i INT = 1;
		DECLARE @LastCode BIGINT ;

		 SELECT @LastCode = MAX(CAST(SUBSTRING(EVoucherCode, 4, LEN(EVoucherCode)-3) AS BIGINT))
         FROM voucher.EVoucher
         WHERE VoucherID = @VoucherID AND EVoucherCode LIKE @Prefix + '%';
		If @LastCode is null set @LastCode = 0;
		WHILE @i <= @Quantity
		BEGIN 
			DECLARE @NextCode Bigint = @LastCode + @i ;
			DECLARE @EVoucherCode VARCHAR(100) = @Prefix + FORMAT(@NextCode,'0000000000');

			INSERT INTO voucher.EVoucher(VoucherID, EVoucherCode, ValidBegin, ValidEnd, ReleaseDate)
			VALUES (@VoucherID, @EVoucherCode, @ValidBegin, @ValidEnd, @ReleaseDate);

			SET @i += 1;
		END
	END
GO 
EXEC sp_rename 'voucher.GenarateVoucher', 'GenerateEVouchers';
EXEC voucher.GenerateEVouchers
     @VoucherID = 'VC100',
     @Quantity = 5,
     @ValidBegin = '2025-09-01',
     @ValidEnd = '2025-12-31',
     @ReleaseDate = '2025-08-31';
SELECT * FROM voucher.EVoucher WHERE  ReleaseDate = '2025-08-31';

--Gán mã voucher cụ thể cho nhân viên.
GO 
CREATE PROCEDURE voucher.AssignVoucherToEmployee
(
	@VoucherID   VARCHAR(100),
	@PhoneNumber VARCHAR(20),
	@Quantity     INT
)
AS
BEGIN 
	SET NOCOUNT ON;
	;WITH cte AS
	( SELECT TOP (@Quantity) EVoucherCode 
	  FROM voucher.EVoucher e 
	  WHERE e.VoucherID = @VoucherID 
	  AND not EXISTS 
	  (
		SELECT 1 FROM voucher.EVoucher_Assignment a 
		WHERE A.EVoucherCode = e.EVoucherCode 
	   )
	  ORDER BY e.ReleaseDate, e.EVoucherCode 
	 )
	 INSERT INTO voucher.EVoucher_Assignment(EVoucherCode, PhoneNumber, AssignedDate, IsUsed, UsedDate)
	 SELECT EVoucherCode, @PhoneNumber,	GETDATE(), 0, NULL
	 FROM cte;
END 
GO 

EXEC voucher.AssignVoucherToEmployee 
	@VoucherID = 'VC100',
	@PhoneNumber ='0980000300',
	@Quantity = 5; 


--- Đánh dấu voucher đã sử dụng, cập nhật useddate + usedby.
GO 
CREATE PROCEDURE voucher.VoucherUsed 
(
	@EVoucherCode VARCHAR(100),
	@PhoneNumber  VARCHAR(20)
)
AS
BEGIN 
	UPDATE voucher.EVoucher_Assignment
	SET IsUsed =1, 
		UsedDate = GETDATE(),
		PhoneNumber = @PhoneNumber 
	WHERE EVoucherCode = @EVoucherCode;
END 
GO 
-- Gia hạn validto.
CREATE PROCEDURE voucher.ExtendVoucher
(
	@EVoucherCode VARCHAR(100),
	@Newvalidend DATE 
)
AS 
BEGIN 
	UPDATE voucher.EVoucher
	SET ValidEnd = @Newvalidend 
	WHERE EVoucherCode = @EVoucherCode ; 
END 
-- Thu hồi voucher chưa dùng.
GO 
CREATE PROCEDURE voucher.DeleteVoucher
(
    @EVoucherCode VARCHAR(100)
)
AS
BEGIN
    DELETE FROM voucher.EVoucher_Assignment
    WHERE EVoucherCode = @EVoucherCode AND IsUsed = 0;
END

GO 
---- Báo cáo số lượng + giá trị 
GO 
CREATE VIEW voucher.Report_VoucherDistributed_Month 
AS 
SELECT 
	FORMAT(E.ReleaseDate ,'yyyy-MM') as YearMonth,
	T.VoucherName , COUNT(E.EVoucherCode) as Total ,
	Sum(T.Price) as TotalValue 
    FROM voucher.EVoucher E
	JOIN voucher.EVoucher_Type T ON E.VoucherID = T.VoucherID
	GROUP BY FORMAT(E.ReleaseDate, 'yyyy-MM'), T.VoucherName;
GO 
SELECT * FROM voucher.Report_VoucherDistributed_Month ;
--Báo cáo số lượng + giá trị voucher đã sử dụng theo thời gian/nhân viên.
go 
CREATE VIEW voucher.Report_Voucher_Used_Employee 
AS
SELECT  
    A.PhoneNumber,
	Empl.FullName,
	A.UsedDate,
    T.VoucherName , 
	COUNT(A.EVoucherCode) as Total ,
	SUM(T.Price) as TotalUsed 
FROM voucher.EVoucher_Assignment A 
Join hr.Employee Empl on A.PhoneNumber = Empl.PhoneNumber
Join voucher.EVoucher E on A.EVoucherCode = E.EVoucherCode
Join voucher.EVoucher_Type T on E.VoucherID = T.VoucherID
where A.IsUsed = 1 
Group by A.PhoneNumber, Empl.FullName, A.UsedDate, T.VoucherName
go 
SELECT * FROM voucher.Report_Voucher_Used_Employee  ;
--Thống kê tồn kho voucher.
GO 
CREATE VIEW voucher.Inventory 
AS
WITH cte AS
(
    SELECT 
        E.VoucherID,
        COUNT(E.EVoucherCode) AS TotalValid
    FROM voucher.EVoucher E
    WHERE NOT EXISTS (
        SELECT 1
        FROM voucher.EVoucher_Assignment A
        WHERE A.EVoucherCode = E.EVoucherCode
    )
    GROUP BY E.VoucherID
)
SELECT 
	T.VoucherID , T.VoucherName, T.Price , 
	Isnull(cte.TotalValid ,0) as Total,
	Isnull(cte.TotalValid,0) * T.Price as TotalValue 
	From voucher.EVoucher_Type T 
	Left Join cte on T.VoucherID = cte.VoucherID;
GO
SELECT * FROM voucher.Inventory   ;
--- Lấy dữ liệu menu tương ứng với App_User.

go
--User → User_Role_Ref → Role → Role_Menu_Ref → Menu

CREATE PROCEDURE app.GetMenuByUser
(
   @App_User_Id NVARCHAR(50) 
)
AS 
BEGIN 
	SELECT DISTINCT  
      menu.App_Menu_Id,
      menu.Name,
      menu.TranslateKey,
      menu.Url,
      menu.Icon,
      menu.DisplayOrder,
      menu.ParentId
	FROM app.[User] u 
	inner join app.User_Role_Ref urr on urr.App_User_Id = u.App_User_Id
	inner join app.Role r on r.App_Role_Id = urr.App_Role_Id
	inner join app.Role_Menu_Ref rmr on rmr.App_Role_Id=r.App_Role_Id
	inner join app.Menu menu on menu.App_Menu_Id =rmr.App_Menu_Id
	where u.App_User_Id = @App_User_Id
	and u.IsActive =1  
	and menu.IsActive =1 
	order by menu.DisplayOrder;
END 
go 


--test 
EXEC app.GetMenuByUser @App_User_Id = 'user1';


