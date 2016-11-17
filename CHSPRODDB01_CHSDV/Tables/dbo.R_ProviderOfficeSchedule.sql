CREATE TABLE [dbo].[R_ProviderOfficeSchedule]
(
[CentauriProviderOfficeScheduleID] [int] NOT NULL IDENTITY(1000009558, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientProviderOfficeScheduleID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeScheduleHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriProviderOfficeScheduleID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_ProviderOfficeSchedule] ADD CONSTRAINT [PK_CentauriProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([CentauriProviderOfficeScheduleID]) ON [PRIMARY]
GO
