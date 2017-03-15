CREATE TABLE [dbo].[CR4]
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
[03] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [decimal] (30, 7) NULL,
[05] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (30, 7) NULL,
[07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [decimal] (30, 7) NULL,
[10] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [decimal] (16, 4) NULL,
[12] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [decimal] (20, 5) NULL,
[14] [decimal] (30, 7) NULL,
[15] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [decimal] (30, 7) NULL,
[19] [decimal] (30, 7) NULL,
[20] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[21] [decimal] (30, 7) NULL,
[22] [decimal] (20, 5) NULL,
[23] [decimal] (30, 7) NULL,
[24] [decimal] (30, 7) NULL,
[25] [decimal] (20, 5) NULL,
[26] [decimal] (30, 7) NULL,
[27] [decimal] (20, 5) NULL,
[28] [decimal] (30, 7) NULL,
[29] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR4] ADD CONSTRAINT [PK_CR4_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR4_dbo] ON [dbo].[CR4] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
