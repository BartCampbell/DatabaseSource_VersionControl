CREATE TABLE [Result].[MeasureDetail_PCR]
(
[AdjProbability] [decimal] (18, 12) NULL,
[Age] [tinyint] NULL,
[BaseWeight] [decimal] (18, 12) NULL,
[BatchID] [int] NULL,
[BeginDate] [datetime] NULL,
[BeginOrigDate] [datetime] NULL,
[BitProductLines] [bigint] NULL,
[ClinCondID] [int] NULL,
[ClinCondID1] [int] NULL,
[ClinCondID2] [int] NULL,
[ClinCondID3] [int] NULL,
[ClinCondID4] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[DccWeight] [decimal] (18, 12) NULL,
[DccWeight1] [decimal] (18, 12) NULL,
[DccWeight2] [decimal] (18, 12) NULL,
[DccWeight3] [decimal] (18, 12) NULL,
[DccWeight4] [decimal] (18, 12) NULL,
[DemoWeight] [decimal] (18, 12) NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EndDate] [datetime] NULL,
[EndOrigDate] [datetime] NULL,
[Gender] [tinyint] NULL,
[HClinCondWeight] [decimal] (18, 12) NULL,
[OwnerID] [int] NULL,
[ProductLineID] [smallint] NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_PCR_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_PCR_SourceRowID] DEFAULT ((-1)),
[SurgeryWeight] [decimal] (18, 12) NULL,
[TotalWeight] [decimal] (18, 12) NULL,
[Variance] [decimal] (18, 12) NULL,
[XferGroupCount] [int] NULL,
[XferGroupID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_PCR] ADD CONSTRAINT [PK_MeasureDetail_PCR] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_PCR_BatchID] ON [Result].[MeasureDetail_PCR] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_PCR] ON [Result].[MeasureDetail_PCR] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_MeasureDetail_PCR_SourceRowID] ON [Result].[MeasureDetail_PCR] ([SourceRowID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
