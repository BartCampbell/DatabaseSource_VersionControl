CREATE TABLE [dbo].[tblSuspectChartRecLog]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[Log_Date] [smalldatetime] NULL,
[Log_Info] [varchar] (30) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
