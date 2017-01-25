CREATE TABLE [CGF].[MeasureSets]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultAgeBandID] [int] NOT NULL,
[DefaultSeedDate] [datetime] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL,
[IsSysSampleAscending] [bit] NOT NULL,
[MeasureSetGuid] [uniqueidentifier] NOT NULL,
[MeasureSetID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NULL
) ON [PRIMARY]
GO
