CREATE TYPE [Report].[ReportParameters] AS TABLE
(
[ParameterName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [sql_variant] NULL,
PRIMARY KEY CLUSTERED  ([ParameterName])
)
GO
