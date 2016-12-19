CREATE TABLE [dbo].[tblChaseStatus]
(
[ChaseStatus_PK] [int] NOT NULL,
[VendorCodeType] [varchar] (7) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[VendorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[VendorPendReason] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ChaseStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ChartResolutionCode] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CentauriChartStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ContactNote] [varchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Active] [bit] NULL,
[ChaseStatusGroup_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblChaseStatus] ADD CONSTRAINT [PK_tblChaseStatus] PRIMARY KEY CLUSTERED  ([ChaseStatus_PK]) ON [PRIMARY]
GO
