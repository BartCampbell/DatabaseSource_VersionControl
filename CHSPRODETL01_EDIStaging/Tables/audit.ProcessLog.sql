CREATE TABLE [audit].[ProcessLog]
(
[ProcessLogID] [int] NOT NULL IDENTITY(1, 1),
[Process] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Task] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartTime] [datetime] NOT NULL,
[EndTime] [datetime] NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [audit].[ProcessLog] ADD CONSTRAINT [PK_ProcessLog] PRIMARY KEY CLUSTERED  ([ProcessLogID]) ON [PRIMARY]
GO
