CREATE TABLE [dbo].[R_AdvanceInvoiceVendor]
(
[CentauriInvoiceVendorID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientInvoiceVendorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendorHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriInvoiceVendorID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceInvoiceVendor] ADD CONSTRAINT [PK_CentauriInvoiceVendorID] PRIMARY KEY CLUSTERED  ([CentauriInvoiceVendorID]) ON [PRIMARY]
GO
