CREATE TABLE [dbo].[customfieldoption]
(
[ID] [numeric] (18, 0) NOT NULL,
[CUSTOMFIELD] [numeric] (18, 0) NULL,
[CUSTOMFIELDCONFIG] [numeric] (18, 0) NULL,
[PARENTOPTIONID] [numeric] (18, 0) NULL,
[SEQUENCE] [numeric] (18, 0) NULL,
[customvalue] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[optiontype] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[disabled] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[customfieldoption] ADD CONSTRAINT [PK_customfieldoption] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cf_cfoption] ON [dbo].[customfieldoption] ([CUSTOMFIELD]) ON [PRIMARY]
GO
