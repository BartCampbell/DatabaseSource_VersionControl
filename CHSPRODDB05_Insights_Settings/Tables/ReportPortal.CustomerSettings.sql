CREATE TABLE [ReportPortal].[CustomerSettings]
(
[CNetDbName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNetDbServer] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNetUrl] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QmeDbName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QmeDbServer] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QmeOwnerGuid] [uniqueidentifier] NULL,
[QmeUserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QmeUserPwd] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RepoPath] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RptCustID] [smallint] NOT NULL,
[RptRootPath] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RptServer] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RptUserDomain] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RptUserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RptUserPwd] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[CustomerSettings] ADD CONSTRAINT [PK_CustomerSettings] PRIMARY KEY CLUSTERED  ([RptCustID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[CustomerSettings] ADD CONSTRAINT [FK_ReportPortal_CustomerSettings_Customers] FOREIGN KEY ([RptCustID]) REFERENCES [ReportPortal].[Customers] ([RptCustID])
GO
