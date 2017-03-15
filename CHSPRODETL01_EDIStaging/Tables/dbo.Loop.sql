CREATE TABLE [dbo].[Loop]
(
[Id] [int] NOT NULL,
[ParentLoopId] [int] NULL,
[InterchangeId] [int] NOT NULL,
[TransactionSetId] [int] NOT NULL,
[TransactionSetCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SpecLoopId] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartingSegmentId] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityIdentifierCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Loop] ADD CONSTRAINT [PK_Loop_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Loop_22_1582628681__K1_2] ON [dbo].[Loop] ([Id]) INCLUDE ([ParentLoopId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Loop_5_832722019__K1_K6] ON [dbo].[Loop] ([Id], [SpecLoopId]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1582628681_2_1] ON [dbo].[Loop] ([ParentLoopId], [Id])
GO
CREATE STATISTICS [stat_832722019_6_1] ON [dbo].[Loop] ([SpecLoopId], [Id])
GO
