CREATE TABLE [dbo].[CUR]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [decimal] (20, 5) NULL,
[04] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [date] NULL,
[09] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [date] NULL,
[12] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [date] NULL,
[15] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [date] NULL,
[18] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[19] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[20] [date] NULL,
[21] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CUR] ADD CONSTRAINT [PK_CUR_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CUR_dbo] ON [dbo].[CUR] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
