CREATE TABLE [dbo].[MIA]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [decimal] (30, 7) NULL,
[02] [decimal] (36, 9) NULL,
[03] [decimal] (30, 7) NULL,
[04] [decimal] (36, 9) NULL,
[05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (36, 9) NULL,
[07] [decimal] (36, 9) NULL,
[08] [decimal] (36, 9) NULL,
[09] [decimal] (36, 9) NULL,
[10] [decimal] (36, 9) NULL,
[11] [decimal] (36, 9) NULL,
[12] [decimal] (36, 9) NULL,
[13] [decimal] (36, 9) NULL,
[14] [decimal] (36, 9) NULL,
[15] [decimal] (30, 7) NULL,
[16] [decimal] (36, 9) NULL,
[17] [decimal] (36, 9) NULL,
[18] [decimal] (36, 9) NULL,
[19] [decimal] (36, 9) NULL,
[20] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[21] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[22] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[23] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[24] [decimal] (36, 9) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MIA] ADD CONSTRAINT [PK_MIA_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MIA_dbo] ON [dbo].[MIA] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
