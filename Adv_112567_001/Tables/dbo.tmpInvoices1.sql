CREATE TABLE [dbo].[tmpInvoices1]
(
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MemberName] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderName] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[AmountPaid] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Payee] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TotalAmount] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Confirmation #] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Payment Type] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Source] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Notes] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Invoice_PK] [int] NULL
) ON [PRIMARY]
GO
