CREATE TABLE [dbo].[MEA]
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
[02] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [decimal] (38, 10) NULL,
[04] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [decimal] (38, 10) NULL,
[06] [decimal] (38, 10) NULL,
[07] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MEA] ADD CONSTRAINT [PK_MEA_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MEA_dbo] ON [dbo].[MEA] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
