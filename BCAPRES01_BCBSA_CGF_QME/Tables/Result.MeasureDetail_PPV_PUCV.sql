CREATE TABLE [Result].[MeasureDetail_PPV_PUCV]
(
[BatchID] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[DSEntityID] [bigint] NULL,
[DSMemberID] [bigint] NULL,
[ExpectedQty] [decimal] (24, 18) NULL,
[MetricID] [int] NULL,
[Ppv] [decimal] (24, 12) NULL,
[PpvBaseWeight] [decimal] (24, 18) NULL,
[PpvDemoWeight] [decimal] (24, 18) NULL,
[PpvHccWeight] [decimal] (24, 18) NULL,
[PpvTotalWeight] [decimal] (24, 18) NULL,
[Pucv] [decimal] (24, 12) NULL,
[PucvBaseWeight] [decimal] (24, 18) NULL,
[PucvDemoWeight] [decimal] (24, 18) NULL,
[PucvHccWeight] [decimal] (24, 18) NULL,
[PucvTotalWeight] [decimal] (24, 18) NULL,
[Qty] [int] NULL,
[ResultRowGuid] [uniqueidentifier] NULL CONSTRAINT [DF_MeasureDetail_PPV_PUCV_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_PPV_PUCV_SourceRowID] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_PPV_PUCV] ADD CONSTRAINT [PK_Result_MeasureDetail_PPV_PUCV] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
