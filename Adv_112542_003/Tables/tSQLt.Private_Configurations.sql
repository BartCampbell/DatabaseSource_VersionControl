CREATE TABLE [tSQLt].[Private_Configurations]
(
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [sql_variant] NULL
) ON [PRIMARY]
GO
ALTER TABLE [tSQLt].[Private_Configurations] ADD CONSTRAINT [PK__Private___737584F740BA1C0F] PRIMARY KEY CLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
