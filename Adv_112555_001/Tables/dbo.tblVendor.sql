CREATE TABLE [dbo].[tblVendor]
(
[Client_PK] [smallint] NULL,
[Vendor_PK] [int] NOT NULL IDENTITY(1, 1),
[Vendor_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVendor] ADD CONSTRAINT [PK_tblVendor] PRIMARY KEY CLUSTERED  ([Vendor_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblVendorClient] ON [dbo].[tblVendor] ([Client_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
