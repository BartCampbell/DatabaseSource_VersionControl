CREATE TABLE [dbo].[SVD]
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
[02] [decimal] (36, 9) NULL,
[03] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [decimal] (30, 7) NULL,
[06] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SVD] ADD CONSTRAINT [PK_SVD_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SVD_dbo] ON [dbo].[SVD] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
