CREATE TABLE [dbo].[tblProviderOfficeInvoiceSuspect]
(
[ProviderOfficeInvoice_PK] [int] NOT NULL,
[Suspect_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeInvoiceSuspect] ADD CONSTRAINT [PK_tblProviderOfficeInvoiceSuspect] PRIMARY KEY CLUSTERED  ([ProviderOfficeInvoice_PK], [Suspect_PK]) ON [PRIMARY]
GO
