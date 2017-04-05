CREATE TABLE [Ncqa].[MetricKey]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BitProductLines] [bigint] NULL,
[Descr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromAgeMonths] [int] NULL,
[FromAgeYears] [int] NULL,
[Gender] [tinyint] NULL,
[HasAge] [bit] NULL,
[InitAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsValid] [bit] NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureSetID] [int] NOT NULL,
[ToAgeMonths] [int] NULL,
[ToAgeYears] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MetricKey] ADD CONSTRAINT [PK_Ncqa_MetricKey] PRIMARY KEY CLUSTERED  ([InitAbbrev], [MeasureSetID]) ON [PRIMARY]
GO
