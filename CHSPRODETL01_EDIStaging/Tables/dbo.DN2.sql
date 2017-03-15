CREATE TABLE [dbo].[DN2]
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
[02] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [decimal] (30, 7) NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DN2] ADD CONSTRAINT [PK_DN2_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DN2_dbo] ON [dbo].[DN2] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
