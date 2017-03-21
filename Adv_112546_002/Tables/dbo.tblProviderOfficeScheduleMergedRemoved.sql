CREATE TABLE [dbo].[tblProviderOfficeScheduleMergedRemoved]
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
[sch_type] [smallint] NULL
) ON [PRIMARY]
GO
