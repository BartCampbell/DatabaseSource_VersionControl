CREATE TABLE [dbo].[ChartNetImportMemberMeasureSample]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCDeliveryDate] [datetime] NULL,
[SampleType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SampleDrawOrder] [int] NOT NULL,
[PPCPrenatalCareStartDate] [datetime] NULL,
[PPCPrenatalCareEndDate] [datetime] NULL,
[PPCPostpartumCareStartDate] [datetime] NULL,
[PPCPostpartumCareEndDate] [datetime] NULL,
[PPCEnrollmentCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
