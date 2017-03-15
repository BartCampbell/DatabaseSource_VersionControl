CREATE TABLE [dbo].[NM1]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NM1] ADD CONSTRAINT [PK_NM1_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NM1_5_1661248973__K9_K16_K6_K1_K4_K11_K12_K13_K14_K15_K17] ON [dbo].[NM1] ([01], [08], [LoopId], [InterchangeId], [TransactionSetId], [03], [04], [05], [06], [07], [09]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_NM1_22_263671987__K9_K3_K1_K2_K4_K17_K6_K5_K11_K12_K13_K14_K15] ON [dbo].[NM1] ([01], [RevisionId], [InterchangeId], [PositionInInterchange], [TransactionSetId], [09], [LoopId], [ParentLoopId], [03], [04], [05], [06], [07]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NM1_dbo] ON [dbo].[NM1] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1661248973_16_9] ON [dbo].[NM1] ([08], [01])
GO
CREATE STATISTICS [stat_1661248973_16_9_1_2_3_6_4_11_12_13_14_15_17] ON [dbo].[NM1] ([08], [01], [InterchangeId], [PositionInInterchange], [RevisionId], [LoopId], [TransactionSetId], [03], [04], [05], [06], [07], [09])
GO
CREATE STATISTICS [stat_1661248973_17_11_12_13_14_15_9] ON [dbo].[NM1] ([09], [03], [04], [05], [06], [07], [01])
GO
CREATE STATISTICS [stat_1661248973_17_16_1_9_6] ON [dbo].[NM1] ([09], [08], [InterchangeId], [01], [LoopId])
GO
CREATE STATISTICS [_dta_stat_263671987_17_3_1_2] ON [dbo].[NM1] ([09], [RevisionId], [InterchangeId], [PositionInInterchange])
GO
CREATE STATISTICS [stat_1661248973_1_6_4_16] ON [dbo].[NM1] ([InterchangeId], [LoopId], [TransactionSetId], [08])
GO
CREATE STATISTICS [stat_1661248973_1_6_4_2_3_16_9_5_11_12_13_14_15_17] ON [dbo].[NM1] ([InterchangeId], [LoopId], [TransactionSetId], [PositionInInterchange], [RevisionId], [08], [01], [ParentLoopId], [03], [04], [05], [06], [07], [09])
GO
CREATE STATISTICS [_dta_stat_263671987_1_6_4_3] ON [dbo].[NM1] ([InterchangeId], [LoopId], [TransactionSetId], [RevisionId])
GO
CREATE STATISTICS [stat_1661248973_1_5_2_3_16_9_6] ON [dbo].[NM1] ([InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [08], [01], [LoopId])
GO
CREATE STATISTICS [_dta_stat_263671987_1_5_3_2_4_17_9] ON [dbo].[NM1] ([InterchangeId], [ParentLoopId], [RevisionId], [PositionInInterchange], [TransactionSetId], [09], [01])
GO
CREATE STATISTICS [stat_1661248973_1_2_3_16] ON [dbo].[NM1] ([InterchangeId], [PositionInInterchange], [RevisionId], [08])
GO
CREATE STATISTICS [stat_1661248973_1_4_11_12_13_14_15_17] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [03], [04], [05], [06], [07], [09])
GO
CREATE STATISTICS [stat_1661248973_1_4_16_9] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [08], [01])
GO
CREATE STATISTICS [_dta_stat_263671987_1_4_17_9_2_3_6_11_12_13_14_15] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [09], [01], [PositionInInterchange], [RevisionId], [LoopId], [03], [04], [05], [06], [07])
GO
CREATE STATISTICS [stat_1661248973_1_4_6_11_12_13_14_15_17] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [LoopId], [03], [04], [05], [06], [07], [09])
GO
CREATE STATISTICS [stat_1661248973_1_4_6_5_11_12_13_14_15_17_9] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [LoopId], [ParentLoopId], [03], [04], [05], [06], [07], [09], [01])
GO
CREATE STATISTICS [_dta_stat_263671987_1_4_3_2_17_9_6_5_11_12_13_14_15] ON [dbo].[NM1] ([InterchangeId], [TransactionSetId], [RevisionId], [PositionInInterchange], [09], [01], [LoopId], [ParentLoopId], [03], [04], [05], [06], [07])
GO
CREATE STATISTICS [stat_1661248973_6_16_9_1_4_11_12_13_14_15_17] ON [dbo].[NM1] ([LoopId], [08], [01], [InterchangeId], [TransactionSetId], [03], [04], [05], [06], [07], [09])
GO
CREATE STATISTICS [stat_1661248973_6_1_2_3_16_9] ON [dbo].[NM1] ([LoopId], [InterchangeId], [PositionInInterchange], [RevisionId], [08], [01])
GO
CREATE STATISTICS [_dta_stat_263671987_6_3_1_2_4_17] ON [dbo].[NM1] ([LoopId], [RevisionId], [InterchangeId], [PositionInInterchange], [TransactionSetId], [09])
GO
CREATE STATISTICS [stat_1661248973_2_16_9] ON [dbo].[NM1] ([PositionInInterchange], [08], [01])
GO
CREATE STATISTICS [_dta_stat_263671987_2_1_4_17] ON [dbo].[NM1] ([PositionInInterchange], [InterchangeId], [TransactionSetId], [09])
GO
CREATE STATISTICS [stat_1661248973_3_16_9_1_2] ON [dbo].[NM1] ([RevisionId], [08], [01], [InterchangeId], [PositionInInterchange])
GO
CREATE STATISTICS [stat_1661248973_4_1_2_3_16_9] ON [dbo].[NM1] ([TransactionSetId], [InterchangeId], [PositionInInterchange], [RevisionId], [08], [01])
GO
CREATE STATISTICS [_dta_stat_263671987_4_3] ON [dbo].[NM1] ([TransactionSetId], [RevisionId])
GO
