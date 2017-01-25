CREATE TABLE [Ncqa].[MetricDescriptions]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MetricDescriptions] ADD CONSTRAINT [PK_MetricDescriptions] PRIMARY KEY CLUSTERED  ([Abbrev]) ON [PRIMARY]
GO
