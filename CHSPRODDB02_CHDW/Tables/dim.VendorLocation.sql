CREATE TABLE [dim].[VendorLocation]
(
[VendorLocationID] [int] NOT NULL IDENTITY(1, 1),
[VendorID] [int] NOT NULL,
[Addr1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Addr2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_VendorLocation_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_VendorLocation_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[VendorLocation] ADD CONSTRAINT [PK_VendorLocation] PRIMARY KEY CLUSTERED  ([VendorLocationID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_VendorLocation_17_1671677003__K3_K5_K6_K7_K2_1] ON [dim].[VendorLocation] ([Addr1], [City], [State], [Zip], [VendorID]) INCLUDE ([VendorLocationID]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1671677003_2_3_5_6] ON [dim].[VendorLocation] ([VendorID], [Addr1], [City], [State])
GO
ALTER TABLE [dim].[VendorLocation] ADD CONSTRAINT [FK_VendorLocation_Vendor] FOREIGN KEY ([VendorID]) REFERENCES [dim].[Vendor] ([VendorID])
GO
