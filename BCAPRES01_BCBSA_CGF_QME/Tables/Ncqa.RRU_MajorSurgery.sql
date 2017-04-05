CREATE TABLE [Ncqa].[RRU_MajorSurgery]
(
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[RRUMajSurgGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_RRU_MajorSurgery_RRUMajSurgGuid] DEFAULT (newid()),
[RRUMajSurgID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[RRU_MajorSurgery] ADD CONSTRAINT [PK_Ncqa_RRU_MajorSurgery] PRIMARY KEY CLUSTERED  ([RRUMajSurgID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_RRU_MajorSurgery_Codes] ON [Ncqa].[RRU_MajorSurgery] ([MeasureSetID], [Code], [CodeTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_MajorSurgery_CodeID] ON [Ncqa].[RRU_MajorSurgery] ([MeasureSetID], [CodeID]) WHERE ([CodeID] IS NOT NULL) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_RRU_MajorSurgery_RRUMajSurgGuid] ON [Ncqa].[RRU_MajorSurgery] ([RRUMajSurgGuid]) ON [PRIMARY]
GO
