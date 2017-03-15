CREATE TABLE [dbo].[SV3]
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
[03] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [decimal] (30, 7) NULL,
[07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SV3] ADD CONSTRAINT [PK_SV3_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SV3_dbo] ON [dbo].[SV3] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
