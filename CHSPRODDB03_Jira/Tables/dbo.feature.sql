CREATE TABLE [dbo].[feature]
(
[ID] [numeric] (18, 0) NOT NULL,
[FEATURE_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FEATURE_TYPE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[USER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[feature] ADD CONSTRAINT [PK_feature] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [feature_id_userkey] ON [dbo].[feature] ([ID], [USER_KEY]) ON [PRIMARY]
GO
