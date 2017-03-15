CREATE TABLE [adv].[tblProviderOfficeScheduleStage]
(
[ProviderOfficeSchedule_PK] [int] NOT NULL,
[Project_PK] [smallint] NOT NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[Sch_User_PK] [smallint] NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[followup] [smallint] NULL,
[AddInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_type] [smallint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblProvid__LoadD__5912BDED] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderOfficeScheduleHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeScheduleStage] ADD CONSTRAINT [PK_tblProviderOfficeScheduleStage] PRIMARY KEY CLUSTERED  ([ProviderOfficeSchedule_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
