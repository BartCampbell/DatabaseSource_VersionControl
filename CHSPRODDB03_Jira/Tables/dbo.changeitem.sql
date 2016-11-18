CREATE TABLE [dbo].[changeitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[groupid] [numeric] (18, 0) NULL,
[FIELDTYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OLDVALUE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OLDSTRING] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NEWVALUE] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NEWSTRING] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[changeitem] ADD CONSTRAINT [PK_changeitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [chgitem_field] ON [dbo].[changeitem] ([FIELD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [chgitem_chggrp] ON [dbo].[changeitem] ([groupid]) ON [PRIMARY]
GO
