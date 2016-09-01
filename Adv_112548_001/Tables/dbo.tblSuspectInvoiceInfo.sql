CREATE TABLE [dbo].[tblSuspectInvoiceInfo]
(
[Suspect_PK] [bigint] NOT NULL,
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendor_PK] [tinyint] NULL,
[dtInsert] [smalldatetime] NULL CONSTRAINT [DF_tblSuspectInvoiceInfo_dtInsert] DEFAULT (getdate()),
[User_PK] [smallint] NULL,
[IsApproved] [bit] NULL,
[Update_User_PK] [int] NULL,
[dtUpdate] [smalldatetime] NULL,
[Invoice_PK] [int] NOT NULL IDENTITY(1, 1),
[AmountPaid] [smallmoney] NULL,
[Check_Transaction_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentType_PK] [tinyint] NULL,
[InvoiceAccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inv_File] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectInvoiceInfo] ADD CONSTRAINT [PK_tblSuspectInvoiceInfo] PRIMARY KEY CLUSTERED  ([Invoice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectInvoiceInfo_Suspect] ON [dbo].[tblSuspectInvoiceInfo] ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
