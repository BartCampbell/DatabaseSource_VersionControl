CREATE TABLE [dbo].[LIN]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[ErrorId] [int] NULL,
[01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[02] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[05] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[06] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[07] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[08] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[09] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[10] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[11] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[12] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[13] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[14] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[15] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[16] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[17] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[18] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[19] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[20] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[21] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[22] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[23] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[24] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[25] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[26] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[27] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[28] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[29] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[30] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[31] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LIN] ADD CONSTRAINT [PK_LIN_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LIN_dbo] ON [dbo].[LIN] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
