CREATE TABLE [dbo].[DMG]
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
[02] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [decimal] (30, 7) NULL,
[10] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DMG] ADD CONSTRAINT [PK_DMG_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DMG_5_2032726294__K1_K5_K2_K3_K11_K4_K10] ON [dbo].[DMG] ([InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [03], [TransactionSetId], [02]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DMG_dbo] ON [dbo].[DMG] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_2032726294_10_1_5_4] ON [dbo].[DMG] ([02], [InterchangeId], [ParentLoopId], [TransactionSetId])
GO
CREATE STATISTICS [stat_2032726294_10_5_4] ON [dbo].[DMG] ([02], [ParentLoopId], [TransactionSetId])
GO
CREATE STATISTICS [stat_2032726294_11_1_5] ON [dbo].[DMG] ([03], [InterchangeId], [ParentLoopId])
GO
CREATE STATISTICS [stat_2032726294_11_1_2_3_4_10] ON [dbo].[DMG] ([03], [InterchangeId], [PositionInInterchange], [RevisionId], [TransactionSetId], [02])
GO
CREATE STATISTICS [stat_2032726294_11_3_1] ON [dbo].[DMG] ([03], [RevisionId], [InterchangeId])
GO
CREATE STATISTICS [stat_2032726294_1_5_4_11_10] ON [dbo].[DMG] ([InterchangeId], [ParentLoopId], [TransactionSetId], [03], [02])
GO
CREATE STATISTICS [stat_2032726294_1_4_3_2_11] ON [dbo].[DMG] ([InterchangeId], [TransactionSetId], [RevisionId], [PositionInInterchange], [03])
GO
CREATE STATISTICS [_dta_stat_635149308_5_11] ON [dbo].[DMG] ([ParentLoopId], [03])
GO
CREATE STATISTICS [stat_2032726294_5_3_1] ON [dbo].[DMG] ([ParentLoopId], [RevisionId], [InterchangeId])
GO
CREATE STATISTICS [stat_2032726294_2_11_1_5] ON [dbo].[DMG] ([PositionInInterchange], [03], [InterchangeId], [ParentLoopId])
GO
CREATE STATISTICS [stat_2032726294_3_1_2_11] ON [dbo].[DMG] ([RevisionId], [InterchangeId], [PositionInInterchange], [03])
GO
CREATE STATISTICS [stat_2032726294_4_11_1] ON [dbo].[DMG] ([TransactionSetId], [03], [InterchangeId])
GO
