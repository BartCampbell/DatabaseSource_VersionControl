CREATE TABLE [dbo].[customfieldvalue]
(
[ID] [numeric] (18, 0) NOT NULL,
[ISSUE] [numeric] (18, 0) NULL,
[CUSTOMFIELD] [numeric] (18, 0) NULL,
[PARENTKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[STRINGVALUE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NUMBERVALUE] [numeric] (18, 6) NULL,
[TEXTVALUE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DATEVALUE] [datetime] NULL,
[VALUETYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[customfieldvalue] ADD CONSTRAINT [PK_customfieldvalue] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cfvalue_issue] ON [dbo].[customfieldvalue] ([ISSUE], [CUSTOMFIELD]) ON [PRIMARY]
GO
