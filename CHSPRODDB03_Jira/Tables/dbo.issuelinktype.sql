CREATE TABLE [dbo].[issuelinktype]
(
[ID] [numeric] (18, 0) NOT NULL,
[LINKNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[INWARD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OUTWARD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[pstyle] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[issuelinktype] ADD CONSTRAINT [PK_issuelinktype] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [linktypename] ON [dbo].[issuelinktype] ([LINKNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [linktypestyle] ON [dbo].[issuelinktype] ([pstyle]) ON [PRIMARY]
GO
