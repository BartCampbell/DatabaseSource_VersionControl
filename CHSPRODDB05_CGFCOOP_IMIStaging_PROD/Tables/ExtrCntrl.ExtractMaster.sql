CREATE TABLE [ExtrCntrl].[ExtractMaster]
(
[ExtractMasterID] [int] NOT NULL IDENTITY(1, 1),
[ExtractControlID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractRequestingDept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractRequestingUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractDesc] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InitialCreateDate] [datetime] NULL,
[InitialCreateUser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractOutputCode] [int] NULL,
[CurrentVersion] [numeric] (5, 2) NULL,
[InProductionFlag] [bit] NULL,
[OutputPath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdStoredProcDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdStoredProcSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProdStoredProcName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parameter1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parameter2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parameter3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ExtrCntrl].[ExtractMaster] ADD CONSTRAINT [pk_ExtractMaster] PRIMARY KEY CLUSTERED  ([ExtractMasterID]) ON [PRIMARY]
GO
