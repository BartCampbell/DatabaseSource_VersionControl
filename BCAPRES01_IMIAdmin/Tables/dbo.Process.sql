CREATE TABLE [dbo].[Process]
(
[ProcessID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Process_ProcessID] DEFAULT (newid()),
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCategoryName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobOwnerLoginName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessTypeID] [uniqueidentifier] NULL,
[ScheduledStartTime] [datetime] NULL,
[SubjectAreaID] [uniqueidentifier] NULL,
[TimeBegin] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Process] ADD CONSTRAINT [Process_PK] PRIMARY KEY CLUSTERED  ([ProcessID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Process] ADD CONSTRAINT [ProcessType_Process_FK1] FOREIGN KEY ([ProcessTypeID]) REFERENCES [dbo].[ProcessType] ([ProcessTypeID])
GO
ALTER TABLE [dbo].[Process] ADD CONSTRAINT [SubjectArea_Process_FK1] FOREIGN KEY ([SubjectAreaID]) REFERENCES [dbo].[SubjectArea] ([SubjectAreaID])
GO
