CREATE TABLE [dbo].[OS_PROPERTYENTRY]
(
[entity_name] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[entity_id] [numeric] (19, 0) NOT NULL,
[entity_key] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[key_type] [int] NULL,
[boolean_val] [tinyint] NULL,
[double_val] [float] NULL,
[string_val] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[text_val] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[long_val] [numeric] (19, 0) NULL,
[int_val] [int] NULL,
[date_val] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[OS_PROPERTYENTRY] ADD CONSTRAINT [PK__OS_PROPE__A5F92905F41BEE9E] PRIMARY KEY CLUSTERED  ([entity_name], [entity_id], [entity_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ospe_entityid_idx] ON [dbo].[OS_PROPERTYENTRY] ([entity_id]) ON [PRIMARY]
GO
