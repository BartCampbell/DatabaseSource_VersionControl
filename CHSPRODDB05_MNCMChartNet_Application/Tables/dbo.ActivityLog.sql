CREATE TABLE [dbo].[ActivityLog]
(
[LastActivityDate] [datetime] NOT NULL CONSTRAINT [DF_ActivityLog_LastActivityDate] DEFAULT (getdate()),
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogDate] [datetime] NOT NULL,
[PageTitle] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageUrl] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QueryString] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ActivityL__Objec__196BA376] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActivityLog] ADD CONSTRAINT [PK_ActivityLog] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ActivityLog] ON [dbo].[ActivityLog] ([UserName], [LogDate] DESC, [LogID] DESC) ON [PRIMARY]
GO
