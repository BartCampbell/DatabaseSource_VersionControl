CREATE TABLE [dbo].[users]
(
[id] [numeric] (19, 0) NOT NULL,
[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[password] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[created] [datetime] NULL,
[fullname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[users] ADD CONSTRAINT [PK__users__3213E83FA0E01ED4] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[users] ADD CONSTRAINT [UQ__users__72E12F1B2F2ED3DF] UNIQUE NONCLUSTERED  ([name]) ON [PRIMARY]
GO
