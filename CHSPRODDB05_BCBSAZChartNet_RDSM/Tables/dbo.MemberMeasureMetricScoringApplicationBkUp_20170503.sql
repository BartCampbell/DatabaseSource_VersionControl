CREATE TABLE [dbo].[MemberMeasureMetricScoringApplicationBkUp_20170503]
(
[MemberMeasureMetricScoringID] [int] NOT NULL IDENTITY(1, 1),
[MemberMeasureSampleID] [int] NOT NULL,
[HEDISSubMetricID] [int] NOT NULL,
[DenominatorCount] [int] NOT NULL,
[Denominator] [bit] NOT NULL,
[AdministrativeHitCount] [int] NOT NULL,
[AdministrativeHit] [bit] NOT NULL,
[MedicalRecordHitCount] [int] NOT NULL,
[MedicalRecordHit] [bit] NOT NULL,
[HybridHitCount] [int] NOT NULL,
[HybridHit] [bit] NOT NULL,
[ExclusionCount] [int] NOT NULL,
[Exclusion] [bit] NOT NULL,
[ExclusionReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqExclCount] [int] NOT NULL,
[ReqExclusion] [bit] NOT NULL,
[ReqExclReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleVoidCount] [int] NOT NULL,
[SampleVoid] [bit] NOT NULL,
[SampleVoidReason] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuppIndicator] [bit] NOT NULL,
[PreExclusionAdmin] [bit] NOT NULL,
[PreExclusionValidData] [bit] NOT NULL,
[PreExclusionPlanEmployee] [bit] NOT NULL
) ON [PRIMARY]
GO
