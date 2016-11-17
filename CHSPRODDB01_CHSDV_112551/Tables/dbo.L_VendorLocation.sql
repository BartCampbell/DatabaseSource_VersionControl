CREATE TABLE [dbo].[L_VendorLocation]
(
[L_VendorLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_VendorLocation] ADD CONSTRAINT [PK_L_VendorLocation] PRIMARY KEY CLUSTERED  ([L_VendorLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_VendorLocation] ADD CONSTRAINT [FK_H_Location_RK10] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_VendorLocation] ADD CONSTRAINT [FK_H_Vendor_RK4] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
