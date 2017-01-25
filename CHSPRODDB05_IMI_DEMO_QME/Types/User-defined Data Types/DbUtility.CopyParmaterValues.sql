CREATE TYPE [DbUtility].[CopyParmaterValues] AS TABLE
(
[ParamName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParamValue] [sql_variant] NULL,
PRIMARY KEY CLUSTERED  ([ParamName])
)
GO
