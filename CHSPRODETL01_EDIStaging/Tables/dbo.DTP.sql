CREATE TABLE [dbo].[DTP]
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
[02] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DTP] ADD CONSTRAINT [PK_DTP_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_DTP_5_77243330__K1_K5_K2_K3_K9_K4_K11] ON [dbo].[DTP] ([InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId], [01], [TransactionSetId], [03]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DTP_dbo] ON [dbo].[DTP] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_77243330_9_1_5_2_3] ON [dbo].[DTP] ([01], [InterchangeId], [ParentLoopId], [PositionInInterchange], [RevisionId])
GO
CREATE STATISTICS [stat_77243330_9_1_2_3_4_11] ON [dbo].[DTP] ([01], [InterchangeId], [PositionInInterchange], [RevisionId], [TransactionSetId], [03])
GO
CREATE STATISTICS [stat_77243330_9_3_1] ON [dbo].[DTP] ([01], [RevisionId], [InterchangeId])
GO
CREATE STATISTICS [stat_77243330_11_5_4] ON [dbo].[DTP] ([03], [ParentLoopId], [TransactionSetId])
GO
CREATE STATISTICS [stat_77243330_1_5_3] ON [dbo].[DTP] ([InterchangeId], [ParentLoopId], [RevisionId])
GO
CREATE STATISTICS [stat_77243330_1_3_2_9] ON [dbo].[DTP] ([InterchangeId], [RevisionId], [PositionInInterchange], [01])
GO
CREATE STATISTICS [stat_77243330_1_4_3_2_9_5_11] ON [dbo].[DTP] ([InterchangeId], [TransactionSetId], [RevisionId], [PositionInInterchange], [01], [ParentLoopId], [03])
GO
CREATE STATISTICS [stat_77243330_2_9_1] ON [dbo].[DTP] ([PositionInInterchange], [01], [InterchangeId])
GO
CREATE STATISTICS [stat_77243330_3_1_2_5] ON [dbo].[DTP] ([RevisionId], [InterchangeId], [PositionInInterchange], [ParentLoopId])
GO
CREATE STATISTICS [stat_77243330_4_3] ON [dbo].[DTP] ([TransactionSetId], [RevisionId])
GO
