CREATE TABLE [dbo].[AetnaInvoicing_FacilityRollup]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[TIN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FacilityName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalCSZ] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalCity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhysicalZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCSZ] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingCity] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillingZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AetnaInvoicing_FacilityRollup] ADD CONSTRAINT [UQ__AetnaInv__FBDF78C85813B62A] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
