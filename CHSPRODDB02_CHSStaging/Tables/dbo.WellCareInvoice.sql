CREATE TABLE [dbo].[WellCareInvoice]
(
[InvoiceNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientLastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientFirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrigAmt] [money] NULL,
[Balance] [money] NULL,
[InvDateSent] [datetime] NULL,
[RequesterNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReqState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderPageCount] [float] NULL,
[DaysOld] [float] NULL
) ON [PRIMARY]
GO
