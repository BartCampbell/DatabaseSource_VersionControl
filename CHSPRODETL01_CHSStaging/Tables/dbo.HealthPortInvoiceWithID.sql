CREATE TABLE [dbo].[HealthPortInvoiceWithID]
(
[Invoice #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inv Date] [datetime] NULL,
[Patient ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patient name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider #] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inv Amnt] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAID ] [datetime] NULL
) ON [PRIMARY]
GO
