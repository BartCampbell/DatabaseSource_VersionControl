CREATE TABLE [dbo].[propertydate]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertydate] ADD CONSTRAINT [PK_propertydate] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
