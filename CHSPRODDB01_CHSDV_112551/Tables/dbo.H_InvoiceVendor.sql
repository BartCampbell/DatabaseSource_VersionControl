CREATE TABLE [dbo].[H_InvoiceVendor]
(
[H_InvoiceVendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InvoiceVendor_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientInvoiceVendorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_InvoiceVendor] ADD CONSTRAINT [PK_H_InvoiceVendor] PRIMARY KEY CLUSTERED  ([H_InvoiceVendor_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
