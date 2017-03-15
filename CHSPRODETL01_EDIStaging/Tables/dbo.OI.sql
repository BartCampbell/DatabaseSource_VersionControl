CREATE TABLE [dbo].[OI]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OI] ADD CONSTRAINT [PK_OI_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OI_dbo] ON [dbo].[OI] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
