CREATE TABLE [adv].[tblVendorStage]
(
[Client_PK] [smallint] NULL,
[Vendor_PK] [int] NOT NULL,
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
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VendorHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CVI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblVendorStage] ADD CONSTRAINT [PK_tblVendorStage] PRIMARY KEY CLUSTERED  ([Vendor_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
