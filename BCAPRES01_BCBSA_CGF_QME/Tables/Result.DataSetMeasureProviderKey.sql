CREATE TABLE [Result].[DataSetMeasureProviderKey]
(
[BitSpecialties] [bigint] NOT NULL,
[CountClaims] [bigint] NOT NULL CONSTRAINT [DF_DataSetMeasureProviderKey_CountClaims] DEFAULT ((0)),
[CountDates] [bigint] NOT NULL CONSTRAINT [DF_DataSetMeasureProviderKey_CountDates] DEFAULT ((0)),
[CountMonths] [bigint] NOT NULL CONSTRAINT [DF_DataSetMeasureProviderKey_CountMonths] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[KeyDate] [datetime] NOT NULL,
[MeasureID] [int] NOT NULL,
[RankOrder] [smallint] NOT NULL,
[RecentDate] [datetime] NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataSetMeasureProviderKey_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Result].[DataSetMeasureProviderKey] ADD CONSTRAINT [PK_Result_DataSetMeasureProviderKey] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_DataSetMeasureProviderKey] ON [Result].[DataSetMeasureProviderKey] ([DataRunID], [MeasureID], [KeyDate], [DSMemberID], [RankOrder]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_DataSetMeasureProviderKey_ResultRowGuid] ON [Result].[DataSetMeasureProviderKey] ([ResultRowGuid]) ON [PRIMARY]
GO
