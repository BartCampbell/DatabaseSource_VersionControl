CREATE TABLE [dbo].[tblNPL2Validate]
(
[Suspect_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblNPL2Validate] ON [dbo].[tblNPL2Validate] ([Suspect_PK]) ON [PRIMARY]
GO
