CREATE TABLE [dbo].[N3]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[N3] ADD CONSTRAINT [PK_N3_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_N3_5_1565248631__K1_K5_K2_K3_K4_K9_K10] ON [dbo].[N3] ([InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [TransactionSetId], [01], [02]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_N3_dbo] ON [dbo].[N3] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1565248631_9_10_1_5] ON [dbo].[N3] ([01], [02], [InterchangeId], [ParentLoopId])
GO
CREATE STATISTICS [stat_1565248631_9_10_5_4] ON [dbo].[N3] ([01], [02], [ParentLoopId], [TransactionSetId])
GO
CREATE STATISTICS [stat_1565248631_1_2_3_4_9_10] ON [dbo].[N3] ([InterchangeId], [PositionInInterchange], [RevisionId], [TransactionSetId], [01], [02])
GO
CREATE STATISTICS [stat_1565248631_1_4_2] ON [dbo].[N3] ([InterchangeId], [TransactionSetId], [PositionInInterchange])
GO
CREATE STATISTICS [stat_1565248631_5_2_1] ON [dbo].[N3] ([ParentLoopId], [PositionInInterchange], [InterchangeId])
GO
CREATE STATISTICS [stat_1565248631_2_1_3_4] ON [dbo].[N3] ([PositionInInterchange], [InterchangeId], [RevisionId], [TransactionSetId])
GO
CREATE STATISTICS [stat_1565248631_3_1_5_2_4_9_10] ON [dbo].[N3] ([RevisionId], [InterchangeId], [ParentLoopId], [PositionInInterchange], [TransactionSetId], [01], [02])
GO
CREATE STATISTICS [stat_1565248631_4_1_5_9_10] ON [dbo].[N3] ([TransactionSetId], [InterchangeId], [ParentLoopId], [01], [02])
GO
