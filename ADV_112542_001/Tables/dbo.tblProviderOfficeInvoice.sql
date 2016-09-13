CREATE TABLE [dbo].[tblProviderOfficeInvoice]
(
[ProviderOfficeInvoice_PK] [int] NOT NULL IDENTITY(1, 1),
[ProviderOffice_PK] [bigint] NULL,
[InvoiceNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendor_PK] [tinyint] NULL,
[UploadUser_PK] [smallint] NULL,
[UploadDate] [smalldatetime] NULL,
[AmountPaid] [smallmoney] NULL,
[Check_Transaction_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentType_PK] [tinyint] NULL,
[InvoiceAccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsApproved] [bit] NULL,
[Update_User_PK] [int] NULL,
[dtUpdate] [smalldatetime] NULL,
[Inv_File] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [bit] NULL,
[IsExtracted] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeInvoice] ADD CONSTRAINT [PK_tblProviderOfficeInvoice] PRIMARY KEY CLUSTERED  ([ProviderOfficeInvoice_PK]) ON [PRIMARY]
GO
