CREATE TABLE [adv].[tblVendorHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblVendor__Creat__6F8CDA48] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblVendorHash] ADD CONSTRAINT [PK_tblVendorHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
