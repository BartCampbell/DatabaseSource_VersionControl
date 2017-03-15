CREATE TABLE [dbo].[INV]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [decimal] (20, 5) NULL,
[03] [decimal] (36, 9) NULL,
[04] [decimal] (30, 7) NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [decimal] (36, 9) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INV] ADD CONSTRAINT [PK_INV_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INV_dbo] ON [dbo].[INV] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
