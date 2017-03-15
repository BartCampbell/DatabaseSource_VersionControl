CREATE TABLE [dbo].[CAS]
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
[02] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [decimal] (36, 9) NULL,
[04] [decimal] (30, 7) NULL,
[05] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (36, 9) NULL,
[07] [decimal] (30, 7) NULL,
[08] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [decimal] (36, 9) NULL,
[10] [decimal] (30, 7) NULL,
[11] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [decimal] (36, 9) NULL,
[13] [decimal] (30, 7) NULL,
[14] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [decimal] (36, 9) NULL,
[16] [decimal] (30, 7) NULL,
[17] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [decimal] (36, 9) NULL,
[19] [decimal] (30, 7) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAS] ADD CONSTRAINT [PK_CAS_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAS_dbo] ON [dbo].[CAS] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
