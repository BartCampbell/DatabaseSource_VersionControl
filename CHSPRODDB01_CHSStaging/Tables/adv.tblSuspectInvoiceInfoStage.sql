CREATE TABLE [adv].[tblSuspectInvoiceInfoStage]
(
[Suspect_PK] [bigint] NOT NULL,
[InvoiceNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendor_PK] [tinyint] NULL,
[dtInsert] [smalldatetime] NULL CONSTRAINT [DF_tblSuspectInvoiceInfoStage_dtInsert] DEFAULT (getdate()),
[User_PK] [smallint] NULL,
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
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__LoadD__499B7033] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectUserInvoiceVendorHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendorHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateUserHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUUI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectInvoiceInfoStage] ADD CONSTRAINT [PK_tblSuspectInvoiceInfoStage] PRIMARY KEY CLUSTERED  ([Invoice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
