CREATE TABLE [dbo].[fieldscreentab]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[FIELDSCREEN] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fieldscreentab] ADD CONSTRAINT [PK_fieldscreentab] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldscreen_tab] ON [dbo].[fieldscreentab] ([FIELDSCREEN]) ON [PRIMARY]
GO
