CREATE TABLE [dbo].[tblOneLevel]
(
[id] [smallint] NOT NULL IDENTITY(1, 1),
[title] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [tinyint] NOT NULL,
[p_id] [smallint] NOT NULL,
[max] [smallint] NULL,
[multiple] [smallint] NULL,
[t_index] [smallint] NULL
) ON [PRIMARY]
GO
