CREATE TABLE [dbo].[N4]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[N4] ADD CONSTRAINT [PK_N4_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_N4_5_1613248802__K1_K5_K2_K3_K4_K9_K10_K11] ON [dbo].[N4] ([InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [TransactionSetId], [01], [02], [03]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_N4_dbo] ON [dbo].[N4] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1613248802_9_10_11_1_5] ON [dbo].[N4] ([01], [02], [03], [InterchangeId], [ParentLoopId])
GO
CREATE STATISTICS [stat_1613248802_9_10_11_5_4] ON [dbo].[N4] ([01], [02], [03], [ParentLoopId], [TransactionSetId])
GO
CREATE STATISTICS [stat_1613248802_1_2_3_4_9_10_11] ON [dbo].[N4] ([InterchangeId], [PositionInInterchange], [RevisionId], [TransactionSetId], [01], [02], [03])
GO
CREATE STATISTICS [stat_1613248802_1_4_3_2_5_9_10_11] ON [dbo].[N4] ([InterchangeId], [TransactionSetId], [RevisionId], [PositionInInterchange], [ParentLoopId], [01], [02], [03])
GO
CREATE STATISTICS [stat_1613248802_3_1_5] ON [dbo].[N4] ([RevisionId], [InterchangeId], [ParentLoopId])
GO
CREATE STATISTICS [stat_1613248802_4_1_5_9_10_11] ON [dbo].[N4] ([TransactionSetId], [InterchangeId], [ParentLoopId], [01], [02], [03])
GO
