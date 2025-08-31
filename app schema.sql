USE QuanLyEvoucher ;
GO 

CREATE SCHEMA [app];
GO 


CREATE TABLE [app].[Dic_Domain] (
    App_Dic_Domain_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    DomainCode NVARCHAR(50) NOT NULL,
    ItemCode NVARCHAR(50) NOT NULL,
    ItemValue NVARCHAR(50) NOT NULL,
    DisplayOrder INT,
    Description NVARCHAR(1000)
);


CREATE TABLE [app].[Org] (
    App_Org_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    Code NVARCHAR(50) NOT NULL UNIQUE,
    Name NVARCHAR(250),
    NameEn NVARCHAR(250),
    Type_Id NVARCHAR(50),
    Address NVARCHAR(1000),
    Description NVARCHAR(1000),
    ParentId NVARCHAR(50),
    DisplayOrder INT,
    CONSTRAINT FK_Org_Domain FOREIGN KEY (Type_Id) REFERENCES [app].[Dic_Domain](App_Dic_Domain_Id)
);

CREATE TABLE [app].[Permission] (
    Permission_Id NVARCHAR(50) PRIMARY KEY,
    Code NVARCHAR(50) NOT NULL UNIQUE,
    Name NVARCHAR(250),
    Description NVARCHAR(1000)
);


CREATE TABLE [app].[User] (
    App_User_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    UserName NVARCHAR(50) NOT NULL UNIQUE,
    FullName NVARCHAR(250) NOT NULL,
    Email NVARCHAR(250),
    EmailConfirmed BIT,
    PhoneNumber NVARCHAR(50),
    PhoneNumberConfirmed BIT,
    AccessFailedCount INT,
    IsAdmin BIT,
    PasswordHash NVARCHAR(250),
    LastLogin DATETIME,
    CONSTRAINT FK_User_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[Menu] (
    App_Menu_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    Name NVARCHAR(250) NOT NULL,
    TranslateKey NVARCHAR(250),
    Url NVARCHAR(250),
    Icon NVARCHAR(50),
    DisplayOrder INT,
    ParentId NVARCHAR(50),
    CONSTRAINT FK_Menu_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[Role] (
    App_Role_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Name NVARCHAR(250) NOT NULL,
    Description NVARCHAR(1000),
    CONSTRAINT FK_Role_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[Setting] (
    App_Setting_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Value NVARCHAR(50) NOT NULL,
    Description NVARCHAR(1000),
    CONSTRAINT FK_Setting_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[File] (
    App_File_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    FilePath NVARCHAR(550),
    FileExt NVARCHAR(50) NOT NULL,
    FileName NVARCHAR(250) NOT NULL,
    FileSize INT NOT NULL,
    FileContent VARBINARY(MAX),
    IsContentOnly BIT,
    IsTemp BIT,
    CONSTRAINT FK_File_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[Sequence] (
    App_Sequence_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Type_Id NVARCHAR(50),
    Prefix NVARCHAR(50),
    Length INT,
    SeqValue INT,
    Description NVARCHAR(1000),
    CONSTRAINT FK_Seq_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id),
    CONSTRAINT FK_Seq_Domain FOREIGN KEY (Type_Id) REFERENCES [app].[Dic_Domain](App_Dic_Domain_Id)
);


CREATE TABLE [app].[Log] (
    App_Log_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    App_Org_Id NVARCHAR(50) NOT NULL,
    TableName NVARCHAR(50),
    RowId NVARCHAR(50),
    Action NVARCHAR(50),
    OldValue NVARCHAR(1000),
    NewValue NVARCHAR(1000),
    CONSTRAINT FK_Log_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[AuditTrail] (
    AuditTrail_Id NVARCHAR(50) PRIMARY KEY,
    App_Org_Id NVARCHAR(50) NOT NULL,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    TableName NVARCHAR(50),
    RowId NVARCHAR(50),
    ColumnName NVARCHAR(250) NOT NULL,
    Action NVARCHAR(50),
    OldValue NVARCHAR(1000),
    NewValue NVARCHAR(1000),
    CONSTRAINT FK_AuditTrail_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[UserSession] (
    Session_Id NVARCHAR(50) PRIMARY KEY,
    App_User_Id NVARCHAR(50) NOT NULL,
    Token NVARCHAR(500) NOT NULL,
    ExpireAt DATETIME NOT NULL,
    IsActive BIT NOT NULL,
    CONSTRAINT FK_Session_User FOREIGN KEY (App_User_Id) REFERENCES [app].[User](App_User_Id)
);


CREATE TABLE [app].[Role_Permission_Ref] (
    Role_Permission_Ref_Id NVARCHAR(50) PRIMARY KEY,
    App_Role_Id NVARCHAR(50) NOT NULL,
    Permission_Id NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_RP_Role FOREIGN KEY (App_Role_Id) REFERENCES [app].[Role](App_Role_Id),
    CONSTRAINT FK_RP_Permission FOREIGN KEY (Permission_Id) REFERENCES [app].[Permission](Permission_Id)
);

CREATE TABLE [app].[Role_Menu_Ref] (
    App_Role_Menu_Ref_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    App_Role_Id NVARCHAR(50) NOT NULL,
    App_Menu_Id NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_RM_Role FOREIGN KEY (App_Role_Id) REFERENCES [app].[Role](App_Role_Id),
    CONSTRAINT FK_RM_Menu FOREIGN KEY (App_Menu_Id) REFERENCES [app].[Menu](App_Menu_Id)
);

CREATE TABLE [app].[User_Org_Ref] (
    App_User_Org_Ref_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    App_User_Id NVARCHAR(50) NOT NULL,
    App_Org_Id NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_UO_User FOREIGN KEY (App_User_Id) REFERENCES [app].[User](App_User_Id),
    CONSTRAINT FK_UO_Org FOREIGN KEY (App_Org_Id) REFERENCES [app].[Org](App_Org_Id)
);


CREATE TABLE [app].[User_Role_Ref] (
    App_User_Role_Ref_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    App_User_Id NVARCHAR(50) NOT NULL,
    App_Role_Id NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_UR_User FOREIGN KEY (App_User_Id) REFERENCES [app].[User](App_User_Id),
    CONSTRAINT FK_UR_Role FOREIGN KEY (App_Role_Id) REFERENCES [app].[Role](App_Role_Id)
);

