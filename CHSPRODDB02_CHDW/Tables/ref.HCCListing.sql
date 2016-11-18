CREATE TABLE [ref].[HCCListing]
(
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunityRAF] [decimal] (6, 3) NULL,
[InstitutionalRAF] [decimal] (6, 3) NULL,
[HCCListingID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[HCCListing] ADD CONSTRAINT [PK_HCCListing] PRIMARY KEY CLUSTERED  ([HCCListingID]) ON [PRIMARY]
GO
