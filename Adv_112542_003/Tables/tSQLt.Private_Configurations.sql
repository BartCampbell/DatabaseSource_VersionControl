CREATE TABLE [tSQLt].[Private_Configurations]
(
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Value] [sql_variant] NULL
) ON [PRIMARY]
GO
ALTER TABLE [tSQLt].[Private_Configurations] ADD CONSTRAINT [PK__Private___737584F7AEC3D058] PRIMARY KEY CLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
