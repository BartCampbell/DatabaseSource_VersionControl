CREATE TABLE [dbo].[licenserolesgroup]
(
[ID] [numeric] (18, 0) NOT NULL,
[LICENSE_ROLE_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GROUP_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PRIMARY_GROUP] [nchar] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[licenserolesgroup] ADD CONSTRAINT [PK_licenserolesgroup] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [licenserolegroup_index] ON [dbo].[licenserolesgroup] ([LICENSE_ROLE_NAME], [GROUP_ID]) ON [PRIMARY]
GO
