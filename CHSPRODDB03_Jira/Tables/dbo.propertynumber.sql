CREATE TABLE [dbo].[propertynumber]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertynumber] ADD CONSTRAINT [PK_propertynumber] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
