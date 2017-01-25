CREATE TABLE [RDSM].[MemberMeasureSample]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate] [datetime] NULL,
[SampleType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleDrawOrder] [int] NOT NULL,
[PPCPrenatalCareStartDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCPrenatalCareEndDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCPostpartumCareStartDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCPostpartumCareEndDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCEnrollmentCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiabetesDiagnosisDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
