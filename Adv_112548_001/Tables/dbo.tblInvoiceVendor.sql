CREATE TABLE [dbo].[tblInvoiceVendor]
(
[InvoiceVendor_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[InvoiceVendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInvoiceVendor] ADD CONSTRAINT [PK_tblInvoiceVendor] PRIMARY KEY CLUSTERED  ([InvoiceVendor_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
