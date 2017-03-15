CREATE TABLE [dbo].[SBR]
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
[02] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SBR] ADD CONSTRAINT [PK_SBR_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SBR_dbo] ON [dbo].[SBR] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
