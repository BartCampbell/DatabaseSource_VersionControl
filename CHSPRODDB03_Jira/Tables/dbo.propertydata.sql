CREATE TABLE [dbo].[propertydata]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertydata] ADD CONSTRAINT [PK_propertydata] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
