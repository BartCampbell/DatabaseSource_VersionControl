CREATE TABLE [CGF].[ResultsByMember]
(
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BeginSeedDate] [datetime] NOT NULL,
[EndSeedDate] [datetime] NOT NULL,
[MeasureSet] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IHDSMemberID] [int] NULL,
[Age] [tinyint] NULL,
[AgeMonths] [smallint] NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataRunGuid] [uniqueidentifier] NOT NULL,
[DataSetGuid] [uniqueidentifier] NOT NULL,
[DataSourceGuid] [uniqueidentifier] NOT NULL,
[ExclusionType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExclusionTypeGuid] [uniqueidentifier] NULL,
[IsDenominator] [int] NULL,
[IsExclusion] [int] NULL,
[IsNumerator] [int] NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureDesc] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureXrefGuid] [uniqueidentifier] NOT NULL,
[Metric] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricDesc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricXrefGuid] [uniqueidentifier] NOT NULL,
[MeasureMetricDesc] [varchar] (145) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResultRowGuid] [uniqueidentifier] NOT NULL,
[ResultType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ResultTypeGuid] [uniqueidentifier] NOT NULL,
[MemberID] [int] NOT NULL,
[EligibilityID] [int] NULL,
[MemberProviderID] [int] NULL,
[ProviderID] [int] NULL,
[ProviderMedicalGroupID] [int] NULL,
[PopulationDesc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentGroupNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentGroupDesc] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx4] ON [CGF].[ResultsByMember] ([Client], [EndSeedDate], [IsDenominator]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ResultsByMember_Client_EndSeedDate_IsDenominator] ON [CGF].[ResultsByMember] ([Client], [EndSeedDate], [IsDenominator]) INCLUDE ([IsNumerator], [Measure], [MeasureDesc], [MeasureMetricDesc], [MeasureSet], [MetricXrefGuid], [PopulationDesc], [ProviderID], [ProviderMedicalGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ResultsByMember_Client_EndSeedDate_IsDenominator_MeasureMetricDesc_ProviderID] ON [CGF].[ResultsByMember] ([Client], [EndSeedDate], [IsDenominator], [MeasureMetricDesc], [ProviderID]) INCLUDE ([IsNumerator], [Measure], [MeasureDesc], [MeasureSet], [MetricXrefGuid], [PopulationDesc], [ProviderMedicalGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx3] ON [CGF].[ResultsByMember] ([DataRunGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [CGF].[ResultsByMember] ([DataRunGuid]) INCLUDE ([CustomerMemberID], [IHDSMemberID], [IsDenominator], [IsExclusion], [IsNumerator], [MeasureXrefGuid], [MetricXrefGuid], [PopulationDesc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ResultsByMember_DataRunGuid_IsDenominator] ON [CGF].[ResultsByMember] ([DataRunGuid], [IsDenominator]) INCLUDE ([IHDSMemberID], [IsNumerator], [MeasureXrefGuid], [MetricXrefGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx1] ON [CGF].[ResultsByMember] ([DataRunGuid], [IsDenominator], [MeasureMetricDesc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResultByMember] ON [CGF].[ResultsByMember] ([IsDenominator], [Client], [EndSeedDate], [PopulationDesc]) INCLUDE ([DataRunGuid], [IHDSMemberID], [IsNumerator], [MeasureXrefGuid], [MetricXrefGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx2] ON [CGF].[ResultsByMember] ([IsDenominator], [MeasureMetricDesc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx7] ON [CGF].[ResultsByMember] ([IsDenominator], [MeasureMetricDesc]) ON [PRIMARY]
GO
CREATE STATISTICS [spidx_ResultByMember] ON [CGF].[ResultsByMember] ([IsDenominator], [Client], [EndSeedDate], [PopulationDesc])
GO
