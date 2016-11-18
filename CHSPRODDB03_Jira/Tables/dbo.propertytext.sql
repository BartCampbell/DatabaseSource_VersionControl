CREATE TABLE [dbo].[propertytext]
(
[ID] [numeric] (18, 0) NOT NULL,
[propertyvalue] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertytext] ADD CONSTRAINT [PK_propertytext] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
