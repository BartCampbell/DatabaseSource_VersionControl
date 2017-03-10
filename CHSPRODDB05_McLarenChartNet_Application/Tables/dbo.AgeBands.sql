CREATE TABLE [dbo].[AgeBands]
(
[Metric] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromAgeYears] [smallint] NULL,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotalMonths] [int] NULL,
[Gender] [tinyint] NULL,
[ToAgeYears] [smallint] NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotalMonths] [int] NULL
) ON [PRIMARY]
GO
