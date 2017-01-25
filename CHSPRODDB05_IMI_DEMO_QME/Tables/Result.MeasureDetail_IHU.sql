CREATE TABLE [Result].[MeasureDetail_IHU]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[ExpectedQty] [decimal] (24, 12) NOT NULL,
[MetricID] [int] NOT NULL,
[Ppd] [decimal] (24, 12) NOT NULL,
[PpdBaseWeight] [decimal] (18, 12) NOT NULL,
[PpdDemoWeight] [decimal] (18, 12) NOT NULL,
[PpdHccWeight] [decimal] (18, 12) NOT NULL,
[PpdTotalWeight] [decimal] (18, 12) NOT NULL,
[Pucd] [decimal] (24, 12) NOT NULL,
[PucdBaseWeight] [decimal] (18, 12) NOT NULL,
[PucdDemoWeight] [decimal] (18, 12) NOT NULL,
[PucdHccWeight] [decimal] (18, 12) NOT NULL,
[PucdTotalWeight] [decimal] (18, 12) NOT NULL,
[Qty] [int] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_IHU_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_IHU_SourceRowID] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_IHU] ADD CONSTRAINT [PK_Result_MeasureDetail_IHU] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
