CREATE TABLE [dbo].[III]
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
[02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (264) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [decimal] (30, 7) NULL,
[06] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[III] ADD CONSTRAINT [PK_III_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_III_dbo] ON [dbo].[III] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
