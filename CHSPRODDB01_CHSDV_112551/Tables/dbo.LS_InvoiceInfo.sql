CREATE TABLE [dbo].[LS_InvoiceInfo]
(
[LS_InvoiceInfo_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectUserInvoiceVendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[IsApproved] [bit] NULL,
[Update_User_PK] [int] NULL,
[dtUpdate] [smalldatetime] NULL,
[Invoice_PK] [int] NOT NULL,
[AmountPaid] [smallmoney] NULL,
[Check_Transaction_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentType_PK] [tinyint] NULL,
[InvoiceAccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inv_File] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [bit] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_InvoiceInfo] ADD CONSTRAINT [PK_LS_InvoiceInfo] PRIMARY KEY CLUSTERED  ([LS_InvoiceInfo_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_InvoiceInfo] ADD CONSTRAINT [FK_L_SuspectUserInvoiceVendor_RK] FOREIGN KEY ([L_SuspectUserInvoiceVendor_RK]) REFERENCES [dbo].[L_SuspectUserInvoiceVendor] ([L_SuspectUserInvoiceVendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
