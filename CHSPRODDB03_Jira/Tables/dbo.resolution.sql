CREATE TABLE [dbo].[resolution]
(
[ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[pname] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICONURL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[resolution] ADD CONSTRAINT [PK_resolution] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
