CREATE TABLE [stage].[ProviderSchedule_ADV]
(
[CentauriProviderOfficeScheduleID] [int] NOT NULL,
[CentauriProviderOfficeID] [int] NOT NULL,
[CentauriProjectID] [int] NULL,
[CentauriLastUserID] [int] NULL,
[CentauriScheduledUserID] [int] NULL,
[CentauriScheduleTypeID] [int] NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[followup] [smallint] NULL,
[AddInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
