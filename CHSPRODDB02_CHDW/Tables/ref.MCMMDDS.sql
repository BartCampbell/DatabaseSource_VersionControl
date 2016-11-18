CREATE TABLE [ref].[MCMMDDS]
(
[MedicalConditionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiseaseCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reserve1] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedConToDisease] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiseaseToMedCon] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve2] [varchar] (34) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
