CREATE TABLE [dbo].[issue_field_option_scope]
(
[ID] [numeric] (18, 0) NOT NULL,
[OPTION_ID] [numeric] (18, 0) NULL,
[ENTITY_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SCOPE_TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issue_field_option_scope] ADD CONSTRAINT [PK_issue_field_option_scope] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
