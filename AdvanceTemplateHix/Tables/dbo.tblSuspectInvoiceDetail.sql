CREATE TABLE [dbo].[tblSuspectInvoiceDetail]
(
[Invoice_PK] [int] NOT NULL,
[Suspect_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectInvoiceDetail] ADD CONSTRAINT [PK_tblSuspectInvoiceDetail] PRIMARY KEY CLUSTERED  ([Invoice_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
