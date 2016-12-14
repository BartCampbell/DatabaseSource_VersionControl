CREATE TABLE [dbo].[MediSpan_INDGIND_Stage]
(
[GPI] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reserve1] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MedConRestrictionCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndicatedMedConCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MicroOrganismCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RoleOfTherapyCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutcomeCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TreatmentRankCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcceptanceLevel] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProxyCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProxyOnly] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserve2] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GPI] ON [dbo].[MediSpan_INDGIND_Stage] ([GPI]) INCLUDE ([IndicatedMedConCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IndicatedMedConCode] ON [dbo].[MediSpan_INDGIND_Stage] ([IndicatedMedConCode]) INCLUDE ([GPI]) ON [PRIMARY]
GO
