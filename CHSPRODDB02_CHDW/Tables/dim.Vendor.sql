CREATE TABLE [dim].[Vendor]
(
[VendorID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NOT NULL,
[ClientVendorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientVendorName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_Vendor_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NOT NULL CONSTRAINT [DF_Vendor_LastUpdate] DEFAULT (getdate()),
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Vendor] ADD CONSTRAINT [PK_Vendor] PRIMARY KEY CLUSTERED  ([VendorID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Vendor_17_132195521__K2_K1_K3] ON [dim].[Vendor] ([ClientID], [VendorID], [ClientVendorID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[Vendor] ADD CONSTRAINT [FK_Vendor_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
