CREATE TABLE [dbo].[PortalTaskRunLog]
(
[PortalTaskRunLogID] [uniqueidentifier] NOT NULL,
[TaskName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartTime] [datetime] NOT NULL,
[EndTime] [datetime] NULL,
[IsComplete] [bit] NOT NULL,
[Status] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentComplete] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastStatusUpdate] [datetime] NULL,
[SerializedTaskObject] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SerializedTaskType] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalTaskRunLog] ADD CONSTRAINT [PK_PortalTaskRunLog] PRIMARY KEY CLUSTERED  ([PortalTaskRunLogID]) ON [PRIMARY]
GO
