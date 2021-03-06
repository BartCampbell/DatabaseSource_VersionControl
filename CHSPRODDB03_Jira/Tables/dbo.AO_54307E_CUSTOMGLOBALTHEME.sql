CREATE TABLE [dbo].[AO_54307E_CUSTOMGLOBALTHEME]
(
[CONTENT_LINK_COLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CONTENT_TEXT_COLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CUSTOM_CSS] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HEADER_BADGE_BGCOLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HEADER_BGCOLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HEADER_LINK_COLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HEADER_LINK_HOVER_BGCOLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HEADER_LINK_HOVER_COLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[HELP_CENTER_TITLE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[LOGO_ID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_54307E_CUSTOMGLOBALTHEME] ADD CONSTRAINT [pk_AO_54307E_CUSTOMGLOBALTHEME_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
