CREATE TABLE [dbo].[CR5]
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
[02] [decimal] (30, 7) NULL,
[03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (30, 7) NULL,
[07] [decimal] (30, 7) NULL,
[08] [decimal] (30, 7) NULL,
[09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [decimal] (30, 7) NULL,
[11] [decimal] (30, 7) NULL,
[12] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [decimal] (30, 7) NULL,
[17] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR5] ADD CONSTRAINT [PK_CR5_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR5_dbo] ON [dbo].[CR5] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
