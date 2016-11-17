CREATE TABLE [adv].[tblInvoiceVendorStage]
(
[InvoiceVendor_PK] [tinyint] NOT NULL,
[InvoiceVendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendorHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblInvoiceVendorStage] ADD CONSTRAINT [PK_tblInvoiceVendor] PRIMARY KEY CLUSTERED  ([InvoiceVendor_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
