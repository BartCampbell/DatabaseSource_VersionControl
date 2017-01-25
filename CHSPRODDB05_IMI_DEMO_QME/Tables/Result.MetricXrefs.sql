CREATE TABLE [Result].[MetricXrefs]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefID] [int] NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL,
[MetricXrefID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MetricXrefs] ADD CONSTRAINT [PK_Result_MetricXrefs] PRIMARY KEY CLUSTERED  ([MetricXrefID]) ON [PRIMARY]
GO
