CREATE TABLE [dbo].[WellCare_InvoiceMaster]
(
[Customer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice] [float] NULL,
[InvoiceDate] [datetime] NULL,
[PatientName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient DOB] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Site Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGES] [float] NULL,
[Open Balance] [money] NULL,
[ExtractedFlag] [int] NULL,
[DuplicateFlag] [int] NULL
) ON [PRIMARY]
GO
