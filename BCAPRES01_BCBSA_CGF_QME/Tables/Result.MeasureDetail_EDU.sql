CREATE TABLE [Result].[MeasureDetail_EDU]
(
[BatchID] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[DSEntityID] [bigint] NULL,
[DSMemberID] [bigint] NULL,
[ExpectedQty] [decimal] (24, 12) NULL,
[MetricID] [int] NULL,
[Ppv] [decimal] (24, 12) NULL,
[PpvBaseWeight] [decimal] (18, 12) NULL,
[PpvDemoWeight] [decimal] (18, 12) NULL,
[PpvHccWeight] [decimal] (18, 12) NULL,
[PpvTotalWeight] [decimal] (18, 12) NULL,
[Pucv] [decimal] (24, 12) NULL,
[PucvBaseWeight] [decimal] (18, 12) NULL,
[PucvDemoWeight] [decimal] (18, 12) NULL,
[PucvHccWeight] [decimal] (18, 12) NULL,
[PucvTotalWeight] [decimal] (18, 12) NULL,
[Qty] [int] NULL,
[ResultRowGuid] [uniqueidentifier] NULL CONSTRAINT [DF_MeasureDetail_EDU_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NULL,
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
