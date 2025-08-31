CREATE DATABASE QuanLyEvoucher;
GO

USE QuanLyEvoucher;
GO

-- Schema hr

CREATE SCHEMA hr AUTHORIZATION dbo;
GO

CREATE TABLE [hr].[Employee] 
(
    FullName          NVARCHAR(100) NOT NULL,
    PhoneNumber       VARCHAR(20)   PRIMARY KEY, 
    dob               DATE          NOT NULL, 
    Email             NVARCHAR(255) NOT NULL CHECK (Email LIKE '_%@_%._%'),
    IDPassportNumber  VARCHAR(50)   NOT NULL UNIQUE
);
GO

CREATE TABLE [hr].[Budget]
(
    BudgetId      INT IDENTITY(1,1) PRIMARY KEY, 
    PhoneNumber   VARCHAR(20), 
    FullName      NVARCHAR(100) NOT NULL,
    BudgetVoucher INT NOT NULL,
    YearMonth     CHAR(7) NOT NULL,
    FOREIGN KEY (PhoneNumber) REFERENCES [hr].[Employee](PhoneNumber) 
);
GO


-- Schema voucher

CREATE SCHEMA voucher AUTHORIZATION dbo;
GO

CREATE TABLE [voucher].[EVoucher_Type] 
( 
    VoucherID    VARCHAR(100)  PRIMARY KEY NOT NULL,
    VoucherName  NVARCHAR(100) NOT NULL,
    Price        INT,
    Prio_queue   INT,
    ValidValue   NVARCHAR(100)
);

CREATE TABLE [voucher].[EVoucher]
(
    VoucherID     VARCHAR(100),
    EVoucherCode  VARCHAR(100) PRIMARY KEY NOT NULL,
    ValidBegin    DATE NOT NULL, 
    ValidEnd      DATE NOT NULL, 
    ReleaseDate   DATE NOT NULL,
    FOREIGN KEY (VoucherID) REFERENCES [voucher].[EVoucher_Type](VoucherID)
);

CREATE TABLE [voucher].[EVoucher_Assignment]
(
    AssignmentId  INT IDENTITY(1,1) PRIMARY KEY,
    EVoucherCode  VARCHAR(100) NOT NULL,
    PhoneNumber   VARCHAR(20) NOT NULL,
    AssignedDate  DATE NOT NULL DEFAULT GETDATE(),
    IsUsed        BIT  NOT NULL DEFAULT 0,
    UsedDate      DATE NULL,
    FOREIGN KEY (EVoucherCode) REFERENCES [voucher].[EVoucher](EVoucherCode),
    FOREIGN KEY (PhoneNumber) REFERENCES [hr].[Employee](PhoneNumber)
);
GO


-- Import nhân viên 
INSERT INTO [hr].[Employee](FullName,PhoneNumber,dob,Email,IDPassportNumber)
SELECT * FROM [dbo].[Sheet1$];

-- Import ngân sách tháng 5
INSERT INTO [hr].[Budget] (PhoneNumber, FullName, BudgetVoucher, YearMonth)
SELECT DISTINCT 
   [TÀI KHOẢN (SĐT)] AS PhoneNumber,
   [HỌ VÀ TÊN NHÂN VIÊN] AS FullName,
   CAST(CAST(REPLACE([NGÂN SÁCH VOUCHER], ',', '') AS FLOAT) AS INT) AS BudgetVoucher,
   '2022-05' AS YearMonth
FROM [dbo].[bgt5]
WHERE [TÀI KHOẢN (SĐT)] IS NOT NULL 
  AND [HỌ VÀ TÊN NHÂN VIÊN] IS NOT NULL;

-- Import ngân sách tháng 6
INSERT INTO [hr].[Budget] (PhoneNumber, FullName, BudgetVoucher, YearMonth)
SELECT DISTINCT 
   [TÀI KHOẢN (SĐT)] AS PhoneNumber,
   [HỌ VÀ TÊN NHÂN VIÊN] AS FullName,
   CAST(CAST(REPLACE([NGÂN SÁCH VOUCHER], ',', '') AS FLOAT) AS INT) AS BudgetVoucher,
   '2022-06' AS YearMonth
FROM [dbo].[bgt6]
WHERE [TÀI KHOẢN (SĐT)] IS NOT NULL 
  AND [HỌ VÀ TÊN NHÂN VIÊN] IS NOT NULL;

-- Import EVoucher loại VC100
INSERT INTO voucher.EVoucher (VoucherID, EVoucherCode, ValidBegin, ValidEnd, ReleaseDate)
SELECT
    [MÃ LOẠI VOUCHER],
    [MÃ E-VOUCHER],
    CONVERT(DATE, [HẠN TỪ NGÀY], 103),
    CONVERT(DATE, [HẠN ĐẾN NGÀY], 103),
    CONVERT(DATE, [NGÀY PHÁT HÀNH], 103)
FROM dbo.vc100
WHERE [MÃ E-VOUCHER] IS NOT NULL;
--
INSERT INTO voucher.EVoucher (VoucherID, EVoucherCode, ValidBegin, ValidEnd, ReleaseDate)
SELECT
    [MÃ LOẠI VOUCHER],
    [MÃ E-VOUCHER],
    CONVERT(DATE, [HẠN TỪ NGÀY], 103),
    CONVERT(DATE, [HẠN ĐẾN NGÀY], 103),
    CONVERT(DATE, [NGÀY PHÁT HÀNH], 103)
FROM dbo.vc500
WHERE [MÃ E-VOUCHER] IS NOT NULL;
--
INSERT INTO voucher.EVoucher (VoucherID, EVoucherCode, ValidBegin, ValidEnd, ReleaseDate)
SELECT
    [MÃ LOẠI VOUCHER],
    [MÃ E-VOUCHER],
    CONVERT(DATE, [HẠN TỪ NGÀY], 103),
    CONVERT(DATE, [HẠN ĐẾN NGÀY], 103),
    CONVERT(DATE, [NGÀY PHÁT HÀNH], 103)
FROM dbo.vc500
WHERE [MÃ E-VOUCHER] IS NOT NULL;

-- Store Procedure cho EVoucher_Type

GO 
CREATE PROCEDURE [voucher].[alter_Evoucher_type] 
(
    @voucherId   VARCHAR(100) = NULL, 
    @voucherName NVARCHAR(100) = NULL,
    @Price       INT = NULL, 
    @Prio_queue  INT = NULL,
    @ValidValue  NVARCHAR(100) = NULL,
    @sql         NVARCHAR(50),
    @pageIndex   INT = 1,      
    @pageSize    INT = 10      
)
AS 
BEGIN 
    SET NOCOUNT ON;

    -- Insert 
    IF @sql = 'insert'
    BEGIN  
        INSERT INTO voucher.EVoucher_Type (VoucherID, VoucherName, Price, Prio_queue, ValidValue)
        VALUES (@voucherId, @voucherName, @Price, @Prio_queue, @ValidValue);
    END 

    -- Update 
    IF @sql = 'update'
    BEGIN 
        UPDATE voucher.EVoucher_Type
        SET VoucherName = @voucherName,
            Price       = @Price,
            Prio_queue  = @Prio_queue,
            ValidValue  = @ValidValue
        WHERE VoucherID = @voucherId;	
    END 

    -- Delete 
    IF @sql = 'delete'
    BEGIN 
        DELETE FROM voucher.EVoucher_Type 
        WHERE VoucherID = @voucherId;	 
    END  

    -- Select by Id
    IF @sql = 'select'
    BEGIN  
        SELECT * 
        FROM voucher.EVoucher_Type
        WHERE VoucherID = @voucherId;
    END  

    -- Select paging
    IF @sql = 'paging'
    BEGIN
        DECLARE @offset INT;
        SET @offset = (@pageIndex - 1) * @pageSize;

        SELECT * 
        FROM voucher.EVoucher_Type
        ORDER BY VoucherID
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    END
END
GO
SELECT * FROM voucher.EVoucher;
	-- Store Procedure cho EVoucher
	GO
CREATE PROCEDURE [voucher].[alter_Evoucher] 
(
    @VoucherID     VARCHAR(100)= NULL,
    @EVoucherCode  VARCHAR(100)=  NULL,
    @ValidBegin    DATE = NULL, 
    @ValidEnd      DATE = NULL, 
    @ReleaseDate   DATE = NULL,
    @sql           NVARCHAR(50),
    @pageIndex   INT = 1,      
    @pageSize    INT = 10      
)
AS 
BEGIN 
    SET NOCOUNT ON;

    -- Insert 
    IF @sql = 'insert'
    BEGIN  
        INSERT INTO voucher.EVoucher (VoucherID,  EVoucherCode, ValidBegin, ValidEnd , ReleaseDate)
        VALUES (@VoucherID,  @EVoucherCode, @ValidBegin, @ValidEnd , @ReleaseDate);
    END 

    -- Update 
    IF @sql = 'update'
    BEGIN 
        UPDATE voucher.EVoucher
        SET VoucherID = @VoucherId,
            ValidBegin  = @ValidBegin,
            ValidEnd  = @ValidEnd,
            ReleaseDate  = @ReleaseDate
        WHERE EVoucherCode = @EVoucherCode
    END 

    -- Delete 
    IF @sql = 'delete'
    BEGIN 
        DELETE FROM voucher.EVoucher
        WHERE EVoucherCode = @EVoucherCode;	 
    END  

    -- Select by Id<EVoucherCode >
    IF @sql = 'select'
    BEGIN  
        SELECT * 
        FROM voucher.EVoucher
        WHERE EVoucherCode = @EVoucherCode;
    END  

    -- Select paging
    IF @sql = 'paging'
    BEGIN
        DECLARE @offset INT;
        SET @offset = (@pageIndex - 1) * @pageSize;

        SELECT * 
        FROM voucher.EVoucher
        ORDER BY EVoucherCode
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    END
END
GO
SELECT * FROM voucher.EVoucher;

	-- Store Procedure cho EVoucher_Assignment
Go
CREATE PROCEDURE [voucher].[alter_Evoucher_Assigment] 
(
    @EVoucherCode  VARCHAR(100) = NULL,
    @PhoneNumber   VARCHAR(20) = NULL,
    @AssignedDate  DATE = NULL,
    @IsUsed        BIT  = 0,
    @UsedDate      DATE = NULL,
    @sql           NVARCHAR(50),
    @pageIndex     INT = 1,      
    @pageSize      INT = 10      
)
AS 
BEGIN 
    SET NOCOUNT ON;

    -- Insert 
    IF @sql = 'insert'
    BEGIN  
        INSERT INTO voucher.EVoucher_Assignment (EVoucherCode, PhoneNumber, AssignedDate, IsUsed, UsedDate)
        VALUES (@EVoucherCode, @PhoneNumber, ISNULL(@AssignedDate, GETDATE()), @IsUsed, @UsedDate);
    END 

    -- Update 
    ELSE IF @sql = 'update'
    BEGIN 
        UPDATE voucher.EVoucher_Assignment
        SET PhoneNumber  = @PhoneNumber,
            AssignedDate = ISNULL(@AssignedDate, GETDATE()),
            IsUsed       = @IsUsed,
            UsedDate     = @UsedDate
        WHERE EVoucherCode = @EVoucherCode;
    END 

    -- Delete 
    ELSE IF @sql = 'delete'
    BEGIN 
        DELETE FROM voucher.EVoucher_Assignment
        WHERE EVoucherCode = @EVoucherCode;	 
    END  

    -- Select by EVoucherCode
    ELSE IF @sql = 'select'
    BEGIN  
        SELECT * 
        FROM voucher.EVoucher_Assignment
        WHERE EVoucherCode = @EVoucherCode;
    END  

    -- Select paging
    ELSE IF @sql = 'paging'
    BEGIN
        DECLARE @offset INT;
        SET @offset = (@pageIndex - 1) * @pageSize;

        SELECT * 
        FROM voucher.EVoucher_Assignment
        ORDER BY EVoucherCode
        OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;
    END
END
GO
