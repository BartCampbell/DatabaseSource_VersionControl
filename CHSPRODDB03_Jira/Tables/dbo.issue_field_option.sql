CREATE TABLE [dbo].[issue_field_option]
(
[ID] [numeric] (18, 0) NOT NULL,
[OPTION_ID] [numeric] (18, 0) NULL,
[FIELD_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[option_value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROPERTIES] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[issue_field_option] ADD CONSTRAINT [PK_issue_field_option] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
