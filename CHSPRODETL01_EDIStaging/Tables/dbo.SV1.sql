CREATE TABLE [dbo].[SV1]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [decimal] (36, 9) NULL,
[03] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [decimal] (30, 7) NULL,
[05] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [decimal] (36, 9) NULL,
[09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[19] [decimal] (36, 9) NULL,
[20] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[21] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SV1] ADD CONSTRAINT [PK_SV1_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SV1_dbo] ON [dbo].[SV1] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
