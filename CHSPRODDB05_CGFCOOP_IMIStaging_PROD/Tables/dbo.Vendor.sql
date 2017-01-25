CREATE TABLE [dbo].[Vendor]
(
[VendorID] [int] NOT NULL IDENTITY(1, 1),
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IRSTaxID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor1099Flag] [bit] NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerVendorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerVendorKey] [int] NULL,
[PrimaryAddress1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryAddress2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryCity] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryState] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryZipCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorShortName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Vendor] ADD CONSTRAINT [pk_Vendor] PRIMARY KEY CLUSTERED  ([VendorID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_pk_Vendor] ON [dbo].[Vendor] ([VendorID])
GO
