CREATE TABLE [dbo].[CR1]
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
[02] [decimal] (20, 5) NULL,
[03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (30, 7) NULL,
[07] [nvarchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR1] ADD CONSTRAINT [PK_CR1_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR1_dbo] ON [dbo].[CR1] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
