CREATE TABLE [ReportPortal].[SecurityPrincipalActivity]
(
[ActivityGuid] [uniqueidentifier] NULL CONSTRAINT [DF_SecurityPrincipalActivity_ActivityGuid] DEFAULT (newid()),
[ActivityID] [bigint] NOT NULL IDENTITY(1, 1),
[BrowserName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrowserType] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BrowserVersion] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrincipalID] [smallint] NOT NULL,
[SessionBeginDate] [datetime] NOT NULL,
[SessionEndDate] [datetime] NULL,
[SessionID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceHost] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceIP] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserAgent] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalActivity] ADD CONSTRAINT [PK_ReportPortal_SecurityPrincipalActivity] PRIMARY KEY CLUSTERED  ([ActivityID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipalActivity_ActivityGuid] ON [ReportPortal].[SecurityPrincipalActivity] ([ActivityGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_SecurityPrincipalActivity] ON [ReportPortal].[SecurityPrincipalActivity] ([PrincipalID], [SessionBeginDate], [SessionID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[SecurityPrincipalActivity] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_SecurityPrincipalActivity_SecurityPrincipals] FOREIGN KEY ([PrincipalID]) REFERENCES [ReportPortal].[SecurityPrincipals] ([PrincipalID])
GO
