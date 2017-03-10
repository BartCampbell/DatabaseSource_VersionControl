CREATE TABLE [dbo].[FaxLog]
(
[FaxLogID] [int] NOT NULL IDENTITY(1, 1),
[FaxLogType] AS (CONVERT([char](1),substring(case  when [OriginalFaxLogID] IS NOT NULL then 'Receive' else 'Send' end,(1),(1)),(0))) PERSISTED,
[FaxLogStatusID] [int] NOT NULL,
[OriginalFaxLogID] [int] NULL,
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_FaxLog_LogDate] DEFAULT (getdate()),
[FaxLogDocID] [smallint] NULL,
[Instructions] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSiteID] [int] NOT NULL,
[Comments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_FaxLog_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FaxLog_CreatedUser] DEFAULT (suser_sname()),
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_FaxLog_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FaxLog_LastChangedUser] DEFAULT (suser_sname())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLog] ADD CONSTRAINT [PK_FaxLog] PRIMARY KEY CLUSTERED  ([FaxLogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLog_FaxLogStatusID] ON [dbo].[FaxLog] ([FaxLogStatusID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLog_FaxLogType] ON [dbo].[FaxLog] ([FaxLogType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLog] ADD CONSTRAINT [FK_FaxLog_FaxLogDocument] FOREIGN KEY ([FaxLogDocID]) REFERENCES [dbo].[FaxLogDocument] ([FaxLogDocID])
GO
ALTER TABLE [dbo].[FaxLog] ADD CONSTRAINT [FK_FaxLog_FaxLogStatus] FOREIGN KEY ([FaxLogStatusID]) REFERENCES [dbo].[FaxLogStatus] ([FaxLogStatusID])
GO
ALTER TABLE [dbo].[FaxLog] ADD CONSTRAINT [FK_FaxLog_ProviderSite] FOREIGN KEY ([ProviderSiteID]) REFERENCES [dbo].[ProviderSite] ([ProviderSiteID])
GO
