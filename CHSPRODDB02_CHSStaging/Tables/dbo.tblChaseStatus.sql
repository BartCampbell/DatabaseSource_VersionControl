CREATE TABLE [dbo].[tblChaseStatus]
(
[ChaseStatus_PK] [int] NOT NULL,
[VendorCodeType] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorPendReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartResolutionCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriChartStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNote] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL,
[ChaseStatusGroup_PK] [tinyint] NULL,
[IsIssue] [bit] NULL
) ON [PRIMARY]
GO
