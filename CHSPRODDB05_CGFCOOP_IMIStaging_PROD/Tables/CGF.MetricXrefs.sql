CREATE TABLE [CGF].[MetricXrefs]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[MeasureXrefID] [int] NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL,
[MetricXrefID] [int] NOT NULL
) ON [PRIMARY]
GO
