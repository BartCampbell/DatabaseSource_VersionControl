CREATE TABLE [dbo].[MemberMeasureSample]
(
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HEDISMeasure] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDate] [datetime] NOT NULL,
[SampleType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SampleDrawOrder] [int] NOT NULL,
[PPCPrenatalCareStartDate] [datetime] NULL,
[PPCPrenatalCareEndDate] [datetime] NULL,
[PPCPostpartumCareStartDate] [datetime] NULL,
[PPCPostpartumCareEndDate] [datetime] NULL,
[PPCEnrollmentCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PPCLastEnrollSegStartDate] [datetime] NULL,
[PPCLastEnrollSegEndDate] [datetime] NULL,
[PPCGestationalDays] [int] NULL,
[DiabetesDiagnosisDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberMeasureSample] ADD CONSTRAINT [PK_MemberMeasureSample_1] PRIMARY KEY CLUSTERED  ([CustomerMemberID], [HEDISMeasure], [EventDate]) ON [PRIMARY]
GO
