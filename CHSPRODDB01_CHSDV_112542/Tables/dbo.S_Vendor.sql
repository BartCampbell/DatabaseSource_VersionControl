CREATE TABLE [dbo].[S_Vendor]
(
[S_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Vendor] ADD CONSTRAINT [PK_S_Vendor] PRIMARY KEY CLUSTERED  ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Vendor] ADD CONSTRAINT [FK_S_Vendor_H_Vendor] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK])
GO
