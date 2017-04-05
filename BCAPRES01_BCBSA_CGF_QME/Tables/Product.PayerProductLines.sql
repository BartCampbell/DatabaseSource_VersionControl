CREATE TABLE [Product].[PayerProductLines]
(
[PayerID] [smallint] NOT NULL,
[ProductLineID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[PayerProductLines] ADD CONSTRAINT [PK_PayerProductLines] PRIMARY KEY CLUSTERED  ([PayerID], [ProductLineID]) ON [PRIMARY]
GO
