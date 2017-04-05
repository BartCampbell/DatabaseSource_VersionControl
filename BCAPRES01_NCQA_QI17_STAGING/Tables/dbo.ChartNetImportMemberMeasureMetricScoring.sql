CREATE TABLE [dbo].[ChartNetImportMemberMeasureMetricScoring]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCDeliveryDate] [datetime] NULL,
[HEDISSubMetric] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DenominatorCount] [int] NOT NULL,
[AdministrativeHitCount] [int] NOT NULL,
[MedicalRecordHitCount] [int] NOT NULL,
[HybridHitCount] [int] NOT NULL
) ON [PRIMARY]
GO
