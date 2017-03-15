CREATE TABLE [dbo].[Segment]
(
[InterchangeId] [int] NOT NULL,
[PositionInInterchange] [int] NOT NULL,
[RevisionId] [int] NOT NULL,
[FunctionalGroupId] [int] NULL,
[TransactionSetId] [int] NULL,
[ParentLoopId] [int] NULL,
[LoopId] [int] NULL,
[Deleted] [bit] NOT NULL,
[SegmentId] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Segment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Segment] ADD CONSTRAINT [PK_Segment_dbo] PRIMARY KEY CLUSTERED  ([InterchangeId], [PositionInInterchange], [RevisionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Segment_dbo] ON [dbo].[Segment] ([InterchangeId], [PositionInInterchange], [RevisionId], [ParentLoopId], [LoopId], [SegmentId]) ON [PRIMARY]
GO
