CREATE TABLE [dbo].[projectcategory]
(
[ID] [numeric] (18, 0) NOT NULL,
[cname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[description] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[projectcategory] ADD CONSTRAINT [PK_projectcategory] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_project_category_name] ON [dbo].[projectcategory] ([cname]) ON [PRIMARY]
GO
