CREATE TABLE [dbo].[MediSpan_MIXI10_Stage]
(
[ICD10_TypeCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD10_UnformattedCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10_FormattedCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD10_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ICD10_UnformattedCode] ON [dbo].[MediSpan_MIXI10_Stage] ([ICD10_UnformattedCode]) INCLUDE ([ICD10_FormattedCode]) ON [PRIMARY]
GO
