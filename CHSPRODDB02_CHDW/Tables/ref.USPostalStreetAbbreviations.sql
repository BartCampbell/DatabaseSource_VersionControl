CREATE TABLE [ref].[USPostalStreetAbbreviations]
(
[USPostalStreetAbbreviationsID] [int] NOT NULL IDENTITY(1, 1),
[CommonStreetName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalStandardAbbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalStandardStreet] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[USPostalStreetAbbreviations] ADD CONSTRAINT [PK_USPostalStreetAbbreviations] PRIMARY KEY CLUSTERED  ([USPostalStreetAbbreviationsID]) ON [PRIMARY]
GO
