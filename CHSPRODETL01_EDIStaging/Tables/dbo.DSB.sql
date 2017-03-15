CREATE TABLE [dbo].[DSB]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [decimal] (30, 7) NULL,
[03] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (36, 9) NULL,
[07] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DSB] ADD CONSTRAINT [PK_DSB_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DSB_dbo] ON [dbo].[DSB] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
