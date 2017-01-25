CREATE TABLE [dbo].[PursuitEventLog]
(
[PursuitEventLogID] [int] NOT NULL IDENTITY(1, 1),
[EventType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PursuitEventID] [int] NOT NULL,
[MeasureComponentID] [int] NULL,
[MedicalRecordKey] [int] NULL,
[EventUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEventLog_EventDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventLog] ADD CONSTRAINT [PK_PursuitEventLog] PRIMARY KEY CLUSTERED  ([PursuitEventLogID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventLog] WITH NOCHECK ADD CONSTRAINT [FK_PursuitEventLog_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
ALTER TABLE [dbo].[PursuitEventLog] ADD CONSTRAINT [FK_PursuitEventLog_PursuitEventLog] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
