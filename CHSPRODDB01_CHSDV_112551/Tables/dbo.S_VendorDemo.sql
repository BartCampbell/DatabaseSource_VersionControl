CREATE TABLE [dbo].[S_VendorDemo]
(
[S_VendorDemo_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Vendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactPerson] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_VendorDemo] ADD CONSTRAINT [PK_S_VendorDemo] PRIMARY KEY CLUSTERED  ([S_VendorDemo_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_VendorDemo] ADD CONSTRAINT [FK_H_Vendor_RK5] FOREIGN KEY ([H_Vendor_RK]) REFERENCES [dbo].[H_Vendor] ([H_Vendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
