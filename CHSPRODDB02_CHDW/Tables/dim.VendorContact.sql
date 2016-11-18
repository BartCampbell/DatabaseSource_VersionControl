CREATE TABLE [dim].[VendorContact]
(
[VendorContactID] [int] NOT NULL IDENTITY(1, 1),
[VendorID] [int] NOT NULL,
[Phone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_VendorContact_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_VendorContact_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[VendorContact] ADD CONSTRAINT [PK_VendorContact] PRIMARY KEY CLUSTERED  ([VendorContactID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_VendorContact_17_1751677288__K3_K4_K2_1] ON [dim].[VendorContact] ([Phone], [Fax], [VendorID]) INCLUDE ([VendorContactID]) ON [PRIMARY]
GO
CREATE STATISTICS [stat_1751677288_2_3_4] ON [dim].[VendorContact] ([VendorID], [Phone], [Fax])
GO
ALTER TABLE [dim].[VendorContact] ADD CONSTRAINT [FK_VendorContact_Vendor] FOREIGN KEY ([VendorID]) REFERENCES [dim].[Vendor] ([VendorID])
GO
