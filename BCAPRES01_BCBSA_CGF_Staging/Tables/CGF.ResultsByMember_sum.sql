CREATE TABLE [CGF].[ResultsByMember_sum]
(
[client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndSeedDate] [datetime] NOT NULL,
[MeasureSet] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureDesc] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureMetricDesc] [varchar] (145) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsNumerator] [int] NULL,
[IsDenominator] [int] NULL,
[ComplianceRate] [numeric] (8, 4) NULL
) ON [PRIMARY]
GO
