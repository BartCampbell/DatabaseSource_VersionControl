CREATE TABLE [dbo].[L_OECVendorContact]
(
[L_OECVendorContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECVendorContact] ADD CONSTRAINT [PK_L_VendorContact] PRIMARY KEY CLUSTERED  ([L_OECVendorContact_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECVendorContact] ADD CONSTRAINT [FK_L_OECVendorContact_H_Contact] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK])
GO
ALTER TABLE [dbo].[L_OECVendorContact] ADD CONSTRAINT [FK_L_OECVendorContact_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECVendorContact] ADD CONSTRAINT [FK_L_OECVendorContact_H_Vendor] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK])
GO
