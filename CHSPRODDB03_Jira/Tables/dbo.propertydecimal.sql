CREATE TABLE [dbo].[propertydecimal]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [numeric] (18, 6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertydecimal] ADD CONSTRAINT [PK_propertydecimal] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
