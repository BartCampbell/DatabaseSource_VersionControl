CREATE TABLE [dbo].[fieldscreenscheme]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldscreenscheme] ADD CONSTRAINT [PK_fieldscreenscheme] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
