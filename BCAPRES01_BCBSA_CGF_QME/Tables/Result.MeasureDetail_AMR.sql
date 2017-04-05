CREATE TABLE [Result].[MeasureDetail_AMR]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[PercentControl] AS (isnull(CONVERT([decimal](18,6),[QtyControl],(0))/nullif(CONVERT([decimal](18,6),[QtyControl],(0))+CONVERT([decimal](18,6),[QtyReliever],(0)),(0)),(0))) PERSISTED NOT NULL,
[PercentReliever] AS (isnull(CONVERT([decimal](18,6),[QtyReliever],(0))/nullif(CONVERT([decimal](18,6),[QtyControl],(0))+CONVERT([decimal](18,6),[QtyReliever],(0)),(0)),(0))) PERSISTED NOT NULL,
[QtyControl] [int] NOT NULL,
[QtyReliever] [int] NOT NULL,
[QtyTotal] AS ([QtyControl]+[QtyReliever]) PERSISTED,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_AMR_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_AMR_SourceRowID] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_AMR] ADD CONSTRAINT [PK_Result_MeasureDetail_AMR] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_AMR_BatchID] ON [Result].[MeasureDetail_AMR] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_AMR] ON [Result].[MeasureDetail_AMR] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_MeasureDetail_AMR_SourceRowID] ON [Result].[MeasureDetail_AMR] ([SourceRowID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
