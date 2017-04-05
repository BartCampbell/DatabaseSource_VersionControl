CREATE TABLE [dbo].[utb_drop_indexinfo]
(
[table_name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[indexname] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tableid] [int] NULL,
[indexkey] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
