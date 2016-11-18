CREATE TABLE [stage].[ProviderLocationScrub]
(
[AddressIn] [varchar] (170) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLocationID] [int] NULL,
[Standardized] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Leading] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Number] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suite] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address Parse.City] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address Parse.State] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address Parse.Zip] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Barcode] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Predirection] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Postdirection] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
