CREATE TABLE [dbo].[tblProviderOfficeInvoiceBucket]
(
[ProviderOfficeInvoiceBucket_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Bucket] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[sortOrder] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeInvoiceBucket] ADD CONSTRAINT [PK_tblProviderOfficeInvoiceBucket] PRIMARY KEY CLUSTERED  ([ProviderOfficeInvoiceBucket_PK]) ON [PRIMARY]
GO
