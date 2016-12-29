CREATE TABLE [dbo].[tblProviderOfficeSchedule]
(
[ProviderOfficeSchedule_PK] [int] NOT NULL IDENTITY(1, 1),
[Project_PK] [smallint] NOT NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[Sch_User_PK] [smallint] NULL,
[LastUpdated_User_PK] [smallint] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[followup] [smallint] NULL,
[AddInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_type] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeSchedule] ADD CONSTRAINT [PK_tblProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([ProviderOfficeSchedule_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProviderOfficeSchedule_1] ON [dbo].[tblProviderOfficeSchedule] ([LastUpdated_User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProviderOfficeSchedule_Prj] ON [dbo].[tblProviderOfficeSchedule] ([Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProviderOfficeSchedule_Office] ON [dbo].[tblProviderOfficeSchedule] ([ProviderOffice_PK], [Project_PK]) INCLUDE ([LastUpdated_Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProviderOfficeSchedule] ON [dbo].[tblProviderOfficeSchedule] ([Sch_User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
