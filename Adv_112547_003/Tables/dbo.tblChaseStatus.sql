CREATE TABLE [dbo].[tblChaseStatus]
(
[ChaseStatus_PK] [int] NOT NULL IDENTITY(1, 1),
[VendorCodeType] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorPendReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartResolutionCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriChartStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNote] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [bit] NULL,
[ChaseStatusGroup_PK] [tinyint] NULL,
[IsIssue] [bit] NULL,
[IsNotContacted] [tinyint] NULL,
[IsSchedulingInProgress] [tinyint] NULL,
[IsScheduled] [tinyint] NULL,
[IsExtracted] [tinyint] NULL,
[IsCNA] [tinyint] NULL,
[IsCoded] [tinyint] NULL,
[ProviderOfficeBucket_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblChaseStatus] ADD CONSTRAINT [PK_tblChaseStatus] PRIMARY KEY CLUSTERED  ([ChaseStatus_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxChaseStatus_ProviderOfficeBucket] ON [dbo].[tblChaseStatus] ([ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
