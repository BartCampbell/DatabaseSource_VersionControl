CREATE TABLE [dbo].[FRM]
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
[02] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[03] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[04] [date] NULL,
[05] [decimal] (12, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FRM] ADD CONSTRAINT [PK_FRM_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FRM_dbo] ON [dbo].[FRM] ([InterchangeId], [PositionInInterchange], [RevisionId], [Deleted], [ParentLoopId], [LoopId]) ON [PRIMARY]
GO
