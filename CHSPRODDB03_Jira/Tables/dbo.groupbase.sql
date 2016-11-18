CREATE TABLE [dbo].[groupbase]
(
[ID] [numeric] (18, 0) NOT NULL,
[groupname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[groupbase] ADD CONSTRAINT [PK_groupbase] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [osgroup_name] ON [dbo].[groupbase] ([groupname]) ON [PRIMARY]
GO
