CREATE TABLE [dbo].[R_AdvanceScheduleType]
(
[CentauriScheduleTypeID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScheduleTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScheduleTypeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriScheduleTypeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceScheduleType] ADD CONSTRAINT [PK_CentauriScheduleTypeID] PRIMARY KEY CLUSTERED  ([CentauriScheduleTypeID]) ON [PRIMARY]
GO
