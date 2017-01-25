CREATE TABLE [dbo].[MemberMeasureSample]
(
[MemberMeasureSampleID] [int] NOT NULL IDENTITY(1, 1),
[ProductLine] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Product] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MemberID] [int] NOT NULL,
[MeasureID] [int] NOT NULL,
[EventDate] [datetime] NOT NULL,
[SampleType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SampleDrawOrder] [int] NOT NULL,
[DischargeDate] AS (case  when [dbo].[GetMeasure]([MeasureID])='MRP' then [EventDate] end),
[PPCDeliveryDate] AS (case  when [dbo].[GetMeasure]([MeasureID])='WOP' OR [dbo].[GetMeasure]([MeasureID])='PPC' OR [dbo].[GetMeasure]([MeasureID])='FPC' then [EventDate] end),
[PPCPrenatalCareStartDate] [datetime] NULL,
[PPCPrenatalCareEndDate] [datetime] NULL,
[PPCPostpartumCareStartDate] [datetime] NULL,
[PPCPostpartumCareEndDate] [datetime] NULL,
[PPCEnrollmentCategoryID] [int] NULL,
[PPCLastEnrollSegStartDate] [datetime] NULL,
[PPCLastEnrollSegEndDate] [datetime] NULL,
[PPCGestationalDays] [smallint] NULL,
[DiabetesDiagnosisDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberMeasureSample] ADD CONSTRAINT [PK_MemberMeasureSample] PRIMARY KEY CLUSTERED  ([MemberMeasureSampleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMeasureSample_MeasureID] ON [dbo].[MemberMeasureSample] ([MeasureID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMeasureSample_MemberID] ON [dbo].[MemberMeasureSample] ([MemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MemberMeasureSample] ON [dbo].[MemberMeasureSample] ([MemberID], [MeasureID], [EventDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MemberMeasureSample_Products] ON [dbo].[MemberMeasureSample] ([ProductLine], [Product]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberMeasureSample] WITH NOCHECK ADD CONSTRAINT [FK_MemberMeasureSample_PPCEnrollmentCategory] FOREIGN KEY ([PPCEnrollmentCategoryID]) REFERENCES [dbo].[PPCEnrollmentCategory] ([PPCEnrollmentCategoryID])
GO
