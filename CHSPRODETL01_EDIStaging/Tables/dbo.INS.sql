CREATE TABLE [dbo].[INS]
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
[03] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[INS] ADD CONSTRAINT [PK_INS_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INS_dbo] ON [dbo].[INS] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
