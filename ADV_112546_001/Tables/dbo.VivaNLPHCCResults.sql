CREATE TABLE [dbo].[VivaNLPHCCResults]
(
[Suspect_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmitInd] [int] NOT NULL,
[NewHCCInd] [int] NOT NULL,
[NewHCC] [int] NULL,
[HigherHCC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
