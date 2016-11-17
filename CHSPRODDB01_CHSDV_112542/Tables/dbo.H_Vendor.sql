CREATE TABLE [dbo].[H_Vendor]
(
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Vendor_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_Vendor_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Vendor] ADD CONSTRAINT [PK_H_Vendor] PRIMARY KEY CLUSTERED  ([H_Vendor_RK]) ON [PRIMARY]
GO
