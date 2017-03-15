CREATE TABLE [dbo].[HI]
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
[02] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[HI] ADD CONSTRAINT [PK_HI_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HI_dbo] ON [dbo].[HI] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
