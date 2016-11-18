CREATE TABLE [dbo].[CONTENTPROPERTIES]
(
[PROPERTYID] [numeric] (19, 0) NOT NULL,
[PROPERTYNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[STRINGVAL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LONGVAL] [numeric] (19, 0) NULL,
[DATEVAL] [datetime] NULL,
[CONTENTID] [numeric] (19, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTENTPROPERTIES] ADD CONSTRAINT [PK__CONTENTP__FCC9FCD332FBB60D] PRIMARY KEY CLUSTERED  ([PROPERTYID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [c_contentproperties_idx] ON [dbo].[CONTENTPROPERTIES] ([CONTENTID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [content_prop_date_idx] ON [dbo].[CONTENTPROPERTIES] ([DATEVAL]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [content_prop_long_idx] ON [dbo].[CONTENTPROPERTIES] ([LONGVAL]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [content_prop_name_idx] ON [dbo].[CONTENTPROPERTIES] ([PROPERTYNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [content_prop_str_idx] ON [dbo].[CONTENTPROPERTIES] ([STRINGVAL]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONTENTPROPERTIES] ADD CONSTRAINT [FK984C5E4C8DD41734] FOREIGN KEY ([CONTENTID]) REFERENCES [dbo].[CONTENT] ([CONTENTID])
GO
