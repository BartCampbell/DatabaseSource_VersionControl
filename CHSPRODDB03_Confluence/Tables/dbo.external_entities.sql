CREATE TABLE [dbo].[external_entities]
(
[id] [numeric] (19, 0) NOT NULL,
[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_entities] ADD CONSTRAINT [PK__external__3213E83F7C720DD0] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ext_ent_name] ON [dbo].[external_entities] ([name]) ON [PRIMARY]
GO
