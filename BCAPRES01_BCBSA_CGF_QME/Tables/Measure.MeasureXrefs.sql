CREATE TABLE [Measure].[MeasureXrefs]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MeasureXrefs_IsEnabled] DEFAULT ((1)),
[MeasClassID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureXrefs_MeasureXrefGuid] DEFAULT (newid()),
[MeasureXrefID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MeasureXrefs] ADD CONSTRAINT [PK_MeasureXrefs] PRIMARY KEY CLUSTERED  ([MeasureXrefID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureXrefs_Abbrevs] ON [Measure].[MeasureXrefs] ([Abbrev], [MeasureSetTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureXrefs_MeasureXrefGuids] ON [Measure].[MeasureXrefs] ([MeasureXrefGuid]) ON [PRIMARY]
GO
