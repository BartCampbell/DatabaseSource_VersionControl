CREATE TABLE [dbo].[HCP]
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
[02] [decimal] (36, 9) NULL,
[03] [decimal] (36, 9) NULL,
[04] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [decimal] (18, 4) NULL,
[06] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [decimal] (36, 9) NULL,
[08] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [decimal] (30, 7) NULL,
[13] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HCP] ADD CONSTRAINT [PK_HCP_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HCP_dbo] ON [dbo].[HCP] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
