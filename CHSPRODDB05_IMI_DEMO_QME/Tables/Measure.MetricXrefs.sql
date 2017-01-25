CREATE TABLE [Measure].[MetricXrefs]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MetricXrefs_IsEnabled] DEFAULT ((1)),
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefID] [int] NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MetricXrefs_MetricXrefGuid] DEFAULT (newid()),
[MetricXrefID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MetricXrefs] ADD CONSTRAINT [PK_MetricXrefs] PRIMARY KEY CLUSTERED  ([MetricXrefID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MetricXrefs_Abbrevs] ON [Measure].[MetricXrefs] ([Abbrev], [MeasureSetTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MetricXrefs_MetricXrefGuids] ON [Measure].[MetricXrefs] ([MetricXrefGuid]) ON [PRIMARY]
GO
