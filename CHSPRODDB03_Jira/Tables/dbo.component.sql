CREATE TABLE [dbo].[component]
(
[ID] [numeric] (18, 0) NOT NULL,
[PROJECT] [numeric] (18, 0) NULL,
[cname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[description] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[URL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LEAD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ASSIGNEETYPE] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[component] ADD CONSTRAINT [PK_component] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_component_name] ON [dbo].[component] ([cname]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_component_project] ON [dbo].[component] ([PROJECT]) ON [PRIMARY]
GO
