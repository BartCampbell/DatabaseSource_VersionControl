CREATE TABLE [dbo].[PER]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PER] ADD CONSTRAINT [PK_PER_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_PER_22_503672842__K9_K11_K13_K15_K1_K4_K5_K12_14_16] ON [dbo].[PER] ([01], [03], [05], [07], [InterchangeId], [TransactionSetId], [ParentLoopId], [04]) INCLUDE ([06], [08]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PER_dbo] ON [dbo].[PER] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_503672842_13_15_9] ON [dbo].[PER] ([05], [07], [01])
GO
CREATE STATISTICS [_dta_stat_503672842_5_1_4] ON [dbo].[PER] ([ParentLoopId], [InterchangeId], [TransactionSetId])
GO
CREATE STATISTICS [_dta_stat_503672842_4_1_9_5_11_13] ON [dbo].[PER] ([TransactionSetId], [InterchangeId], [01], [ParentLoopId], [03], [05])
GO
