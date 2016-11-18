CREATE TABLE [dbo].[favouriteassociations]
(
[ID] [numeric] (18, 0) NOT NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[entitytype] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[entityid] [numeric] (18, 0) NULL,
[SEQUENCE] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[favouriteassociations] ADD CONSTRAINT [PK_favouriteassociations] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [favourite_index] ON [dbo].[favouriteassociations] ([USERNAME], [entitytype], [entityid]) ON [PRIMARY]
GO
