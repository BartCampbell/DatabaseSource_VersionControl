CREATE TABLE [dbo].[utb_drop_indexkeys]
(
[id] [int] NOT NULL,
[indid] [smallint] NOT NULL,
[colid] [smallint] NOT NULL,
[keyno] [smallint] NOT NULL,
[indexfield] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[indexname] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
