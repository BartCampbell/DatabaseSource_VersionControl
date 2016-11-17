CREATE TABLE [dbo].[MediSpan_MCMNAME_Stage]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CountryCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LanguageCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameTypeCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalConditionName] [varchar] (58) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MedicalConditionCode] ON [dbo].[MediSpan_MCMNAME_Stage] ([MedicalConditionCode]) INCLUDE ([MedicalConditionName], [NameTypeCode]) ON [PRIMARY]
GO
