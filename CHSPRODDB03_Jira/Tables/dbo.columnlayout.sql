CREATE TABLE [dbo].[columnlayout]
(
[ID] [numeric] (18, 0) NOT NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SEARCHREQUEST] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[columnlayout] ADD CONSTRAINT [PK_columnlayout] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cl_searchrequest] ON [dbo].[columnlayout] ([SEARCHREQUEST]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cl_username] ON [dbo].[columnlayout] ([USERNAME]) ON [PRIMARY]
GO
