CREATE TABLE [dbo].[tblModelCode]
(
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Code_Description] [varchar] (230) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[V12HCC] [tinyint] NULL,
[V21HCC] [tinyint] NULL,
[V22HCC] [tinyint] NULL,
[RxHCC] [tinyint] NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[IsICD10] [bit] NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblModelCode] ON [dbo].[tblModelCode] ([DiagnosisCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_V12HCC] ON [dbo].[tblModelCode] ([V12HCC]) INCLUDE ([DiagnosisCode]) ON [PRIMARY]
GO
