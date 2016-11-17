CREATE TABLE [dbo].[HealthPortMasterChases]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectPK] [int] NULL,
[MemberLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [date] NULL,
[ProviderID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsScanned] [int] NULL,
[IsCoded] [int] NULL,
[ScannedDate] [date] NULL,
[CodedDate] [date] NULL,
[IsInvoiced] [int] NULL CONSTRAINT [DF__HealthPor__IsInv__7A721B0A] DEFAULT ((0)),
[InvoicedDate] [date] NULL,
[MemberMatchInternalInvoiceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__HealthPor__Membe__7B663F43] DEFAULT ('N'),
[MemberMatchHealthPortInvoiceFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__HealthPor__Membe__7C5A637C] DEFAULT ('N'),
[HPInvoiceDataMatch] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__HealthPor__HPInv__7D4E87B5] DEFAULT ('N'),
[PaidFlag] [int] NULL CONSTRAINT [DF__HealthPor__PaidF__7E42ABEE] DEFAULT ((0)),
[PaidDate] [date] NULL,
[InvoicePaidFlag] [int] NULL CONSTRAINT [DF__HealthPor__Invoi__7F36D027] DEFAULT ((0)),
[InvoiceNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InhouseNotPaidFlag] [int] NULL CONSTRAINT [DF__HealthPor__Inhou__002AF460] DEFAULT ((0)),
[NotInhouseFlag] [int] NULL CONSTRAINT [DF__HealthPor__NotIn__011F1899] DEFAULT ((0)),
[RecordNotes] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HealthPortMasterChases] ADD CONSTRAINT [UQ__HealthPo__FBDF78C835744630] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
