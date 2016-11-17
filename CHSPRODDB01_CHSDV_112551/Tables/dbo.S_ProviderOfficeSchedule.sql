CREATE TABLE [dbo].[S_ProviderOfficeSchedule]
(
[S_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[Sch_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[followup] [smallint] NULL,
[AddInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_type] [smallint] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderOfficeSchedule] ADD CONSTRAINT [PK_S_ProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([S_ProviderOfficeSchedule_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderOfficeSchedule] ADD CONSTRAINT [FK_H_ProviderOfficeSchedule_RK3] FOREIGN KEY ([H_ProviderOfficeSchedule_RK]) REFERENCES [dbo].[H_ProviderOfficeSchedule] ([H_ProviderOfficeSchedule_RK])
GO
