CREATE TABLE [ref].[MCMMICD]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD9Code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MedCondtoICD9] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD9toMedCond] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (34) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
