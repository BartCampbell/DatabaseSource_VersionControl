CREATE TABLE [Result].[MeasureDetail_RRU]
(
[Age] [tinyint] NULL,
[BatchID] [int] NOT NULL,
[CostEMInpatient] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostE__7B309B8C] DEFAULT ((0)),
[CostEMInpatientCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostEMInpatientCapped] DEFAULT ((0)),
[CostEMOutpatient] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostE__7C24BFC5] DEFAULT ((0)),
[CostEMOutpatientCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostEMOutpatientCapped] DEFAULT ((0)),
[CostImaging] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostI__7D18E3FE] DEFAULT ((0)),
[CostImagingCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostImagingCapped] DEFAULT ((0)),
[CostInpatient] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostI__7E0D0837] DEFAULT ((0)),
[CostInpatientCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostInpatientCapped] DEFAULT ((0)),
[CostLab] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostL__7F012C70] DEFAULT ((0)),
[CostLabCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostLabCapped] DEFAULT ((0)),
[CostPharmacy] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostP__7FF550A9] DEFAULT ((0)),
[CostPharmacyCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostPharmacyCapped] DEFAULT ((0)),
[CostProcInpatient] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostP__00E974E2] DEFAULT ((0)),
[CostProcInpatientCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostProcInpatientCapped] DEFAULT ((0)),
[CostProcOutpatient] [decimal] (18, 4) NOT NULL CONSTRAINT [DF__MeasureDe__CostP__01DD991B] DEFAULT ((0)),
[CostProcOutpatientCapped] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_CostProcOutpatientCapped] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DaysAcuteInpatient] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__DaysA__02D1BD54] DEFAULT ((0)),
[DaysAcuteInpatientNotSurg] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__DaysA__03C5E18D] DEFAULT ((0)),
[DaysAcuteInpatientSurg] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__DaysA__04BA05C6] DEFAULT ((0)),
[DaysNonacuteInpatient] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__DaysN__05AE29FF] DEFAULT ((0)),
[DemoWeight] [decimal] (18, 12) NOT NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[FreqAcuteInpatient] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqA__06A24E38] DEFAULT ((0)),
[FreqAcuteInpatientNotSurg] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqA__07967271] DEFAULT ((0)),
[FreqAcuteInpatientSurg] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqA__088A96AA] DEFAULT ((0)),
[FreqED] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqE__097EBAE3] DEFAULT ((0)),
[FreqNonacuteInpatient] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqN__0A72DF1C] DEFAULT ((0)),
[FreqPharmG1] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__0B670355] DEFAULT ((0)),
[FreqPharmG2] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__0C5B278E] DEFAULT ((0)),
[FreqPharmN1] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__0D4F4BC7] DEFAULT ((0)),
[FreqPharmN2] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__0E437000] DEFAULT ((0)),
[FreqProcCABG] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__0F379439] DEFAULT ((0)),
[FreqProcCAD] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__102BB872] DEFAULT ((0)),
[FreqProcCardiacCath] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__111FDCAB] DEFAULT ((0)),
[FreqProcCAS] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__121400E4] DEFAULT ((0)),
[FreqProcCAT] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__1308251D] DEFAULT ((0)),
[FreqProcEndarter] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__13FC4956] DEFAULT ((0)),
[FreqProcPCI] [smallint] NOT NULL CONSTRAINT [DF__MeasureDe__FreqP__14F06D8F] DEFAULT ((0)),
[Gender] [tinyint] NULL,
[HClinCondWeight] [decimal] (18, 12) NOT NULL,
[MM] [tinyint] NOT NULL CONSTRAINT [DF__MeasureDetai__MM__15E491C8] DEFAULT ((0)),
[MMP] [tinyint] NOT NULL CONSTRAINT [DF__MeasureDeta__MMP__16D8B601] DEFAULT ((0)),
[ResultRowGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_ResultRowGuid] DEFAULT (newid()),
[ResultRowID] [bigint] NOT NULL IDENTITY(1, 1),
[RiskCtgyID] [tinyint] NOT NULL,
[SourceRowGuid] [uniqueidentifier] NOT NULL,
[SourceRowID] [bigint] NOT NULL CONSTRAINT [DF_MeasureDetail_RRU_SourceRowID] DEFAULT ((-1)),
[TotalWeight] [decimal] (18, 12) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureDetail_RRU] ADD CONSTRAINT [PK_MeasureDetail_RRU] PRIMARY KEY CLUSTERED  ([ResultRowID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_RRU_BatchID] ON [Result].[MeasureDetail_RRU] ([BatchID], [DataRunID], [DataSetID], [ResultRowGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Result_MeasureDetail_RRU] ON [Result].[MeasureDetail_RRU] ([ResultRowGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Result_MeasureDetail_RRU_SourceRowID] ON [Result].[MeasureDetail_RRU] ([SourceRowID]) WHERE ([SourceRowID]<>(-1)) ON [PRIMARY]
GO
