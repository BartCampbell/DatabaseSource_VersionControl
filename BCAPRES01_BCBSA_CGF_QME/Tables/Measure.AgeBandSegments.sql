CREATE TABLE [Measure].[AgeBandSegments]
(
[AgeBandID] [int] NOT NULL,
[AgeBandSegGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_AgeBandSegments_AgeBandSegGuid] DEFAULT (newid()),
[AgeBandSegID] [int] NOT NULL IDENTITY(1, 1),
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromAgeMonths] [smallint] NULL,
[FromAgeTotMonths] AS ([FromAgeMonths]+((12)*[FromAgeYears])) PERSISTED,
[FromAgeYears] [smallint] NULL,
[Gender] [tinyint] NULL,
[ProductLineID] [smallint] NULL,
[ToAgeMonths] [smallint] NULL,
[ToAgeTotMonths] AS ([ToAgeMonths]+((12)*[ToAgeYears])) PERSISTED,
[ToAgeYears] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[AgeBandSegments] ADD CONSTRAINT [CK_AgeBandSegments_FromAge] CHECK (([FromAgeMonths] IS NULL AND [FromAgeYears] IS NULL OR [FromAgeMonths] IS NOT NULL AND [FromAgeYears] IS NOT NULL))
GO
ALTER TABLE [Measure].[AgeBandSegments] ADD CONSTRAINT [CK_AgeBandSegments_ToAge] CHECK (([ToAgeMonths] IS NULL AND [ToAgeYears] IS NULL OR [ToAgeMonths] IS NOT NULL AND [ToAgeYears] IS NOT NULL))
GO
ALTER TABLE [Measure].[AgeBandSegments] ADD CONSTRAINT [PK_AgeBandSegments] PRIMARY KEY CLUSTERED  ([AgeBandSegID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AgeBandSegments_AgeBandID] ON [Measure].[AgeBandSegments] ([AgeBandID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AgeBandSegments] ON [Measure].[AgeBandSegments] ([AgeBandSegGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AgeBandSegments_TotMonths] ON [Measure].[AgeBandSegments] ([FromAgeTotMonths], [ToAgeTotMonths], [Gender], [ProductLineID], [AgeBandSegID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AgeBandSegments_ProductLineID] ON [Measure].[AgeBandSegments] ([ProductLineID]) ON [PRIMARY]
GO
