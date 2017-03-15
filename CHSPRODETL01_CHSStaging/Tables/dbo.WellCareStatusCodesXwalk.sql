CREATE TABLE [dbo].[WellCareStatusCodesXwalk]
(
[VendorPendReasons] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIOXCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltegraCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartResolutionCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriStatusCode] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriChartStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
