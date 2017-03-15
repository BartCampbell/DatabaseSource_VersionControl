CREATE TABLE [dbo].[WellCareNovemberInvoice]
(
[InvoiceNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimFileNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientLast] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientFirst] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrigAmt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoicePostage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Balance] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvDateSent] [datetime] NULL,
[ReqNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqAddr] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderPageCnt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysOld] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriExtractedFlag] [int] NULL,
[AdvanceMatch] [int] NULL
) ON [PRIMARY]
GO
