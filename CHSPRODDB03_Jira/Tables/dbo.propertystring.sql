CREATE TABLE [dbo].[propertystring]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertystring] ADD CONSTRAINT [PK_propertystring] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
