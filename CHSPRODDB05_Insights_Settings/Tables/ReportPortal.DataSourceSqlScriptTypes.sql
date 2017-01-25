CREATE TABLE [ReportPortal].[DataSourceSqlScriptTypes]
(
[DataSourceSqlScriptTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[DataSourceSqlScriptTypes] ADD CONSTRAINT [PK_ReportPortal_DataSourceSqlScriptTypes] PRIMARY KEY CLUSTERED  ([DataSourceSqlScriptTypeID]) ON [PRIMARY]
GO
