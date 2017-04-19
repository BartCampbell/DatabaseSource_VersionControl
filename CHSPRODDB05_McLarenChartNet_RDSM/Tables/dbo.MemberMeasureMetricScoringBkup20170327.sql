CREATE TABLE [dbo].[MemberMeasureMetricScoringBkup20170327]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDate] [datetime] NOT NULL,
[HEDISSubMetric] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DenominatorCount] [int] NOT NULL,
[AdministrativeHitCount] [int] NOT NULL,
[MedicalRecordHitCount] [int] NOT NULL,
[HybridHitCount] [int] NOT NULL,
[SuppIndicator] [int] NULL,
[ExclusionAdmin] [int] NULL,
[ExclusionValidDataError] [int] NULL,
[ExclusionPlanEmployee] [int] NULL
) ON [PRIMARY]
GO
