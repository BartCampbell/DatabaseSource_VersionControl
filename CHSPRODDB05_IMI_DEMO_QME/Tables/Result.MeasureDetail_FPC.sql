CREATE TABLE [Result].[MeasureDetail_FPC]
(
[BatchID] [int] NOT NULL,
[CountActual] [int] NOT NULL,
[CountExpected] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EnrollDays] [smallint] NOT NULL,
[EnrollMonths] [smallint] NOT NULL,
[GestDays] [smallint] NOT NULL,
[GestStartDate] [datetime] NOT NULL,
[GestWeeks] [smallint] NOT NULL,
[KeyDate] [datetime] NOT NULL,
[LastSegBeginDate] [datetime] NOT NULL,
[LastSegEndDate] [datetime] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_FPC_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[ResultTypeID] [tinyint] NOT NULL,
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_FPC_SourceRowID] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_FPC] ADD CONSTRAINT [PK_MeasureDetail_FPC] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_FPC_BatchID] ON [Result].[MeasureDetail_FPC] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_FPC] ON [Result].[MeasureDetail_FPC] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_MeasureDetail_FPC_SourceRowID] ON [Result].[MeasureDetail_FPC] ([SourceRowID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
