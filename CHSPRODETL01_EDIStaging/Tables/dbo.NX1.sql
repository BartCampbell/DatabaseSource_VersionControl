CREATE TABLE [dbo].[NX1]
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
[03] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NX1] ADD CONSTRAINT [PK_NX1_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NX1_dbo] ON [dbo].[NX1] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
