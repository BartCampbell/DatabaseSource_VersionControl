CREATE TABLE [Measure].[MeasureSets]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultAgeBandID] [int] NOT NULL,
[DefaultSeedDate] [datetime] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MeasureSets_IsEnabled] DEFAULT ((1)),
[IsSysSampleAscending] [bit] NOT NULL CONSTRAINT [DF_MeasureSets_IsSysSampleAscending] DEFAULT ((1)),
[MeasureSetGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureSets_MeasureSetGuid] DEFAULT (newid()),
[MeasureSetID] [int] NOT NULL,
[MeasureSetTypeID] [smallint] NOT NULL,
[SysSampleSetGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureSets_SysSampleSetGuid] DEFAULT (newid())
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[MeasureSets] ADD CONSTRAINT [PK_MeasureSets] PRIMARY KEY CLUSTERED  ([MeasureSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureSets_Abbrevs] ON [Measure].[MeasureSets] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureSets_MeasureSetGuid] ON [Measure].[MeasureSets] ([MeasureSetGuid]) ON [PRIMARY]
GO
