CREATE TABLE [dbo].[genericconfiguration]
(
[ID] [numeric] (18, 0) NOT NULL,
[DATATYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DATAKEY] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[XMLVALUE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[genericconfiguration] ADD CONSTRAINT [PK_genericconfiguration] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [type_key] ON [dbo].[genericconfiguration] ([DATATYPE], [DATAKEY]) ON [PRIMARY]
GO
