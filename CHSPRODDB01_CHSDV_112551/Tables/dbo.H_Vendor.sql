CREATE TABLE [dbo].[H_Vendor]
(
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Vendor_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientVendorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Vendor] ADD CONSTRAINT [PK_H_Vendor] PRIMARY KEY CLUSTERED  ([H_Vendor_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
