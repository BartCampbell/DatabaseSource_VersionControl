CREATE TABLE [dbo].[HealthPortMasterInvoiceFile]
(
[RecID] [float] NULL,
[InvoiceDate] [datetime] NULL,
[InvoiceNum] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevisedInvoiceNum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceMemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceInvoiceNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberMatchDiffInvoice] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__HealthPor__Membe__7760A435] DEFAULT ('N'),
[InvoiceMatch] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__HealthPor__Invoi__7854C86E] DEFAULT ('N')
) ON [PRIMARY]
GO
