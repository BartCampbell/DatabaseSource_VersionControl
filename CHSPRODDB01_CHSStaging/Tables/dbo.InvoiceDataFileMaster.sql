CREATE TABLE [dbo].[InvoiceDataFileMaster]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[InvoiceNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceAmount] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UploadedDate] [date] NULL,
[MemberName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceStatus] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPaid] [int] NULL CONSTRAINT [DF__InvoiceDa__IsPai__0856260D] DEFAULT ((0)),
[DupFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__DupFl__094A4A46] DEFAULT ((0)),
[AdvanceMatch] [int] NULL CONSTRAINT [DF__InvoiceDa__Advan__0A3E6E7F] DEFAULT ((0)),
[ChaseID] [int] NULL,
[ScannedFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__Scann__0B3292B8] DEFAULT ((0)),
[CodedFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__Coded__0C26B6F1] DEFAULT ((0)),
[CNAFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__CNAFl__0D1ADB2A] DEFAULT ((0)),
[InvoicedFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__Invoi__0E0EFF63] DEFAULT ((0)),
[CopyCenterFlag] [int] NULL CONSTRAINT [DF__InvoiceDa__CopyC__0F03239C] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceDataFileMaster] ADD CONSTRAINT [UQ__InvoiceD__360414FEDC62AAF1] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
