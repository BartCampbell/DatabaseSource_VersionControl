CREATE TABLE [Ncqa].[MetricAgeBands]
(
[FromAgeMonths] [smallint] NULL,
[FromAgeYears] [smallint] NULL,
[Gender] [tinyint] NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLine] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeYears] [smallint] NULL
) ON [PRIMARY]
GO
