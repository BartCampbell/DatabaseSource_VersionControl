CREATE TABLE [dbo].[remembermetoken]
(
[ID] [numeric] (18, 0) NOT NULL,
[CREATED] [datetime] NULL,
[TOKEN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[remembermetoken] ADD CONSTRAINT [PK_remembermetoken] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [remembermetoken_username_index] ON [dbo].[remembermetoken] ([USERNAME]) ON [PRIMARY]
GO
