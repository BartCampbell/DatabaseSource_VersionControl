CREATE TABLE [dbo].[S_InvoiceVendorDetail]
(
[S_InvoiceVendorDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_InvoiceVendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceVendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_InvoiceVendorDetail] ADD CONSTRAINT [PK_S_InvoiceVendorDemo] PRIMARY KEY CLUSTERED  ([S_InvoiceVendorDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_InvoiceVendorDetail] ADD CONSTRAINT [FK_H_InvoiceVendor_RK5] FOREIGN KEY ([H_InvoiceVendor_RK]) REFERENCES [dbo].[H_InvoiceVendor] ([H_InvoiceVendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
