CREATE TABLE [Ncqa].[IDSS_MeansAndPercentiles]
(
[FromAgeMonths] [tinyint] NULL,
[FromAgeYears] [tinyint] NULL,
[Gender] [tinyint] NULL,
[IdssColumnID] [int] NULL,
[IdssElementAbbrev] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssElementDescr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssMeanPercentID] [int] NOT NULL IDENTITY(1, 1),
[IdssMeasure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdssYear] [smallint] NOT NULL,
[Mean] [decimal] (18, 6) NULL,
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Percent05] [decimal] (18, 6) NULL,
[Percent10] [decimal] (18, 6) NULL,
[Percent25] [decimal] (18, 6) NULL,
[Percent50] [decimal] (18, 6) NULL,
[Percent75] [decimal] (18, 6) NULL,
[Percent90] [decimal] (18, 6) NULL,
[Percent95] [decimal] (18, 6) NULL,
[ProductClass] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLine] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToAgeMonths] [tinyint] NULL,
[ToAgeYears] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[IDSS_MeansAndPercentiles] ADD CONSTRAINT [PK_Ncqa_IDSS_MeansAndPercentiles] PRIMARY KEY CLUSTERED  ([IdssMeanPercentID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_IDSS_MeansAndPercentiles] ON [Ncqa].[IDSS_MeansAndPercentiles] ([IdssYear], [ProductLine], [ProductClass], [IdssMeasure], [IdssElementAbbrev]) ON [PRIMARY]
GO
