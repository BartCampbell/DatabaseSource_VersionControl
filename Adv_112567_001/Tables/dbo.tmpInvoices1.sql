CREATE TABLE [dbo].[tmpInvoices1]
(
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountPaid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payee] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalAmount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmation #] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payment Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_PK] [int] NULL
) ON [PRIMARY]
GO
