CREATE TABLE [dbo].[licenserolesdefault]
(
[ID] [numeric] (18, 0) NOT NULL,
[LICENSE_ROLE_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[licenserolesdefault] ADD CONSTRAINT [PK_licenserolesdefault] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [licenseroledefault_index] ON [dbo].[licenserolesdefault] ([LICENSE_ROLE_NAME]) ON [PRIMARY]
GO
