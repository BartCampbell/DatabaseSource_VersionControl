CREATE TABLE [dbo].[L_VendorClient]
(
[L_VendorClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_VendorClient] ADD CONSTRAINT [PK_L_VendorClient] PRIMARY KEY CLUSTERED  ([L_VendorClient_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_VendorClient] ADD CONSTRAINT [FK_H_Client_RK11] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_VendorClient] ADD CONSTRAINT [FK_H_Vendor_RK3] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
