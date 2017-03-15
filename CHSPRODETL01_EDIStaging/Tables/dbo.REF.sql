CREATE TABLE [dbo].[REF]
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
[02] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[REF] ADD CONSTRAINT [PK_REF_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_REF_22_887674210__K9_K1_K5_K2_K3_K4_K10] ON [dbo].[REF] ([01], [InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [TransactionSetId], [02]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_REF_dbo] ON [dbo].[REF] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_887674210_9_10_2_1] ON [dbo].[REF] ([01], [02], [PositionInInterchange], [InterchangeId])
GO
CREATE STATISTICS [_dta_stat_887674210_9_1_2] ON [dbo].[REF] ([01], [InterchangeId], [PositionInInterchange])
GO
CREATE STATISTICS [_dta_stat_887674210_10_9_1_5_2] ON [dbo].[REF] ([02], [01], [InterchangeId], [ParentLoopId], [PositionInInterchange])
GO
CREATE STATISTICS [_dta_stat_887674210_10_2] ON [dbo].[REF] ([02], [PositionInInterchange])
GO
CREATE STATISTICS [_dta_stat_887674210_1_10_2_3_9_5] ON [dbo].[REF] ([InterchangeId], [02], [PositionInInterchange], [RevisionId], [01], [ParentLoopId])
GO
CREATE STATISTICS [_dta_stat_887674210_1_5_2] ON [dbo].[REF] ([InterchangeId], [ParentLoopId], [PositionInInterchange])
GO
CREATE STATISTICS [_dta_stat_887674210_1_2_3_9] ON [dbo].[REF] ([InterchangeId], [PositionInInterchange], [RevisionId], [01])
GO
CREATE STATISTICS [_dta_stat_887674210_2_1_3_5] ON [dbo].[REF] ([PositionInInterchange], [InterchangeId], [RevisionId], [ParentLoopId])
GO
CREATE STATISTICS [_dta_stat_887674210_3_9_1_5_2_4_10] ON [dbo].[REF] ([RevisionId], [01], [InterchangeId], [ParentLoopId], [PositionInInterchange], [TransactionSetId], [02])
GO
