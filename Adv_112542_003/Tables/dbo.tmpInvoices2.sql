CREATE TABLE [dbo].[tmpInvoices2]
(
[Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MemberName] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Provider_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ProviderName] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Address] [varchar] (150) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ State] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ AmountPaid ] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TotalAmount] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Confirmation #] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Payment Type] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Payee] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Date] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Invoice_PK] [int] NULL
) ON [PRIMARY]
GO
