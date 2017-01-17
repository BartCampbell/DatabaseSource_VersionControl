CREATE TABLE [dbo].[L_OECVendorLocation]
(
[L_OECVendorLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECVendorLocation] ADD CONSTRAINT [PK_L_VendorLocation] PRIMARY KEY CLUSTERED  ([L_OECVendorLocation_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_OECVendorLocation] ADD CONSTRAINT [FK_L_OECVendorLocation_H_Location] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK])
GO
ALTER TABLE [dbo].[L_OECVendorLocation] ADD CONSTRAINT [FK_L_OECVendorLocation_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
ALTER TABLE [dbo].[L_OECVendorLocation] ADD CONSTRAINT [FK_L_OECVendorLocation_H_Vendor] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK])
GO
