CREATE TABLE [dbo].[MemberMeasureMetricScoring]
(
[MemberMeasureMetricScoringID] [int] NOT NULL IDENTITY(1, 1),
[MemberMeasureSampleID] [int] NOT NULL,
[HEDISSubMetricID] [int] NOT NULL,
[DenominatorCount] [int] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_DenominatorCount] DEFAULT ((0)),
[Denominator] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_DenominatorCount1] DEFAULT ((0)),
[AdministrativeHitCount] [int] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_AdministrativeHitCount] DEFAULT ((0)),
[AdministrativeHit] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_AdministrativeHitCount1] DEFAULT ((0)),
[MedicalRecordHitCount] [int] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_MedicalRecordHitCount] DEFAULT ((0)),
[MedicalRecordHit] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_MedicalRecordHitCount1] DEFAULT ((0)),
[HybridHitCount] [int] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_HybridHitCount] DEFAULT ((0)),
[HybridHit] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_HybridHitCount1] DEFAULT ((0)),
[ExclusionCount] [int] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_ExclusionCount] DEFAULT ((0)),
[Exclusion] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_Exclusion] DEFAULT ((0)),
[ExclusionReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqExclCount] [int] NOT NULL CONSTRAINT [DF__MemberMea__ReqEx__1C5D1EBA] DEFAULT ((0)),
[ReqExclusion] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_ReqExclusion] DEFAULT ((0)),
[ReqExclReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleVoidCount] [int] NOT NULL CONSTRAINT [DF__MemberMea__Sampl__3CC9EE4C] DEFAULT ((0)),
[SampleVoid] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_SampleVoid] DEFAULT ((0)),
[SampleVoidReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuppIndicator] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_SuppIndicator] DEFAULT ((0)),
[PreExclusionAdmin] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_ExclusionAdmin] DEFAULT ((0)),
[PreExclusionValidData] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_ExclusionValidData] DEFAULT ((0)),
[PreExclusionPlanEmployee] [bit] NOT NULL CONSTRAINT [DF_MemberMeasureMetricScoring_ExclusionPlanEmployee] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberMeasureMetricScoring] ADD CONSTRAINT [PK_MemberMeasureMetricScoring] PRIMARY KEY CLUSTERED  ([MemberMeasureMetricScoringID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMeasureMetricScoring_HEDISSubMetricID] ON [dbo].[MemberMeasureMetricScoring] ([HEDISSubMetricID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberMeasureMetricScoring_MemberMeasureSampleID] ON [dbo].[MemberMeasureMetricScoring] ([MemberMeasureSampleID], [HEDISSubMetricID]) INCLUDE ([AdministrativeHitCount], [ExclusionCount], [HybridHitCount], [MedicalRecordHitCount], [ReqExclCount], [SampleVoidCount]) ON [PRIMARY]
GO
