CREATE TABLE [dbo].[CR8]
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
[02] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [date] NULL,
[04] [date] NULL,
[05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR8] ADD CONSTRAINT [PK_CR8_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR8_dbo] ON [dbo].[CR8] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
