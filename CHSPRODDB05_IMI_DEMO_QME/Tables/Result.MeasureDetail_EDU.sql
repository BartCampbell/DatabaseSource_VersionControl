CREATE TABLE [Result].[MeasureDetail_EDU]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[ExpectedQty] [decimal] (24, 12) NOT NULL,
[MetricID] [int] NOT NULL,
[Ppv] [decimal] (24, 12) NOT NULL,
[PpvBaseWeight] [decimal] (18, 12) NOT NULL,
[PpvDemoWeight] [decimal] (18, 12) NOT NULL,
[PpvHccWeight] [decimal] (18, 12) NOT NULL,
[PpvTotalWeight] [decimal] (18, 12) NOT NULL,
[Pucv] [decimal] (24, 12) NOT NULL,
[PucvBaseWeight] [decimal] (18, 12) NOT NULL,
[PucvDemoWeight] [decimal] (18, 12) NOT NULL,
[PucvHccWeight] [decimal] (18, 12) NOT NULL,
[PucvTotalWeight] [decimal] (18, 12) NOT NULL,
[Qty] [int] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_EDU_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_EDU_SourceRowID] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_EDU] ADD CONSTRAINT [PK_Result_MeasureDetail_EDU] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_EDU_BatchID] ON [Result].[MeasureDetail_EDU] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_EDU] ON [Result].[MeasureDetail_EDU] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_MeasureDetail_EDU_SourceRowID] ON [Result].[MeasureDetail_EDU] ([SourceRowID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
