CREATE TABLE [dbo].[MOA]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [decimal] (20, 5) NULL,
[02] [decimal] (36, 9) NULL,
[03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [decimal] (36, 9) NULL,
[09] [decimal] (36, 9) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MOA] ADD CONSTRAINT [PK_MOA_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MOA_dbo] ON [dbo].[MOA] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
