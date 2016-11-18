CREATE TABLE [stage].[Vendor]
(
[VendorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentauriClientID] [int] NOT NULL,
[VendorTIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorTINName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
