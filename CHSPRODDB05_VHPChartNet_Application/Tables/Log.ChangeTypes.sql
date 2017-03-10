CREATE TABLE [Log].[ChangeTypes]
(
[ChngTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[ChangeTypes] ADD CONSTRAINT [PK_ChangeTypes] PRIMARY KEY CLUSTERED  ([ChngTypeID]) ON [PRIMARY]
GO
