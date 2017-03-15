CREATE TABLE [dbo].[CR6]
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
[02] [date] NULL,
[03] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [date] NULL,
[06] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [date] NULL,
[10] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [date] NULL,
[13] [date] NULL,
[14] [date] NULL,
[15] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [date] NULL,
[19] [date] NULL,
[20] [date] NULL,
[21] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CR6] ADD CONSTRAINT [PK_CR6_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CR6_dbo] ON [dbo].[CR6] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
