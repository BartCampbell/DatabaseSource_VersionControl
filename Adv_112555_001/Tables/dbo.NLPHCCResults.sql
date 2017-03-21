CREATE TABLE [dbo].[NLPHCCResults]
(
[Suspect_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmitInd] [int] NOT NULL CONSTRAINT [DF_NLPHCCResults_SubmitInd] DEFAULT ((0)),
[NewHCCInd] [int] NOT NULL CONSTRAINT [DF_NLPHCCResults_NewHCCInd] DEFAULT ((0)),
[NewHCC] [int] NULL,
[HigherHCC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
