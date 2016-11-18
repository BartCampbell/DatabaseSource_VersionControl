CREATE TABLE [dbo].[WPSModelCode]
(
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code_Description] [varchar] (230) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[V12HCC] [tinyint] NULL,
[V21HCC] [tinyint] NULL,
[V22HCC] [tinyint] NULL,
[RxHCC] [tinyint] NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[IsICD10] [bit] NOT NULL
) ON [PRIMARY]
GO
