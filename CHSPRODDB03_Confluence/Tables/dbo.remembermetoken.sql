CREATE TABLE [dbo].[remembermetoken]
(
[id] [numeric] (19, 0) NOT NULL,
[username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[created] [numeric] (19, 0) NOT NULL,
[token] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[remembermetoken] ADD CONSTRAINT [PK__remember__3213E83FEC168D09] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [rmt_username_idx] ON [dbo].[remembermetoken] ([username]) ON [PRIMARY]
GO
