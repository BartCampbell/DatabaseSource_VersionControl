CREATE TABLE [dbo].[CR2]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [int] NULL,
[02] [decimal] (30, 7) NULL,
[03] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (30, 7) NULL,
[07] [decimal] (30, 7) NULL,
[08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR2] ADD CONSTRAINT [PK_CR2_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR2_dbo] ON [dbo].[CR2] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
