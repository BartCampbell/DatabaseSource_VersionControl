CREATE TABLE [adv].[tblInvoiceVendorHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblInvoic__Creat__4012D150] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblInvoiceVendorHash] ADD CONSTRAINT [PK_tblInvoiceVendorHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
