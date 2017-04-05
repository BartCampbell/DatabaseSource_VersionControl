CREATE TABLE [Result].[RiskHCCDetail]
(
[Age] [tinyint] NULL,
[BaseWeight] [decimal] (24, 18) NOT NULL,
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DemoWeight] [decimal] (24, 18) NOT NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[Gender] [tinyint] NULL,
[HClinCondWeight] [decimal] (24, 18) NOT NULL,
[MeasureID] [int] NOT NULL,
[MetricID] [int] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Result_RiskHCCDetail_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_Result_RiskHCCDetail_SourceRowID] DEFAULT ((-1)),
[TotalWeight] [decimal] (24, 18) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[RiskHCCDetail] ADD CONSTRAINT [PK_Result_RiskHCCDetail] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_RiskHCCDetail_BatchID] ON [Result].[RiskHCCDetail] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_RiskHCCDetail] ON [Result].[RiskHCCDetail] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_RiskHCCDetail_SourceRowID] ON [Result].[RiskHCCDetail] ([SourceRowID], [EvalTypeID]) INCLUDE ([BatchID], [DSEntityID], [DSMemberID], [MetricID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
