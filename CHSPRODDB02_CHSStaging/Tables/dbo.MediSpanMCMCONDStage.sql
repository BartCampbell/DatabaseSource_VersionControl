CREATE TABLE [dbo].[MediSpanMCMCONDStage]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConditionType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassificationOnlyFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GenderCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PregnancyCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LactationCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromAge] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThroughAge] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeUnitsCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DurationCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve] [varchar] (41) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_MCMCOND_LoadDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
