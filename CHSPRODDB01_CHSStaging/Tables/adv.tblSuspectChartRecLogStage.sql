CREATE TABLE [adv].[tblSuspectChartRecLogStage]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[Log_Date] [smalldatetime] NULL,
[Log_Info] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
