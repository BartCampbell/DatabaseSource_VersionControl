CREATE TABLE [dbo].[jiraeventtype]
(
[ID] [numeric] (18, 0) NOT NULL,
[TEMPLATE_ID] [numeric] (18, 0) NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[event_type] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraeventtype] ADD CONSTRAINT [PK_jiraeventtype] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
