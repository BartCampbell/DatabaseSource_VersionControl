CREATE TABLE [Log].[Activity]
(
[ActivityID] [bigint] NOT NULL,
[LastActivityDate] [datetime] NOT NULL CONSTRAINT [DF_ActivityLog_LastActivityDate] DEFAULT (getdate()),
[LogDate] [datetime] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[ObjectName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Activity__Object__589C25F3] DEFAULT (''),
[PageTitle] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageUrl] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QueryString] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[Activity] ADD CONSTRAINT [PK_ActivityLog] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
ALTER TABLE [Log].[Activity] ADD CONSTRAINT [FK_ReportPortal_Activity_SecurityPrincipalActivity] FOREIGN KEY ([ActivityID]) REFERENCES [ReportPortal].[SecurityPrincipalActivity] ([ActivityID])
GO
