CREATE TABLE [dbo].[os_user]
(
[id] [numeric] (19, 0) NOT NULL,
[username] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[passwd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_user] ADD CONSTRAINT [PK__os_user__3213E83F519F5C5C] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[os_user] ADD CONSTRAINT [UQ__os_user__F3DBC572564C7F5A] UNIQUE NONCLUSTERED  ([username]) ON [PRIMARY]
GO
