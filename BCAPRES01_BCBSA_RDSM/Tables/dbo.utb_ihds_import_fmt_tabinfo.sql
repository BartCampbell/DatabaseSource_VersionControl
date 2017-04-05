CREATE TABLE [dbo].[utb_ihds_import_fmt_tabinfo]
(
[txt] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rowid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[utb_ihds_import_fmt_tabinfo] ADD CONSTRAINT [pk1] PRIMARY KEY CLUSTERED  ([Rowid]) ON [PRIMARY]
GO
