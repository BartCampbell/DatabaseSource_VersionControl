CREATE TABLE [dbo].[HCCListing]
(
[HCCVersion] [int] NULL,
[HCCVersionYear] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommunityRAF] [decimal] (6, 3) NULL,
[InstitutionalRAF] [decimal] (6, 3) NULL,
[HCCListingID] [int] NOT NULL IDENTITY(1, 1),
[ChronicFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HCCListing] ADD CONSTRAINT [PK_HCCListing] PRIMARY KEY CLUSTERED  ([HCCListingID]) ON [PRIMARY]
GO
