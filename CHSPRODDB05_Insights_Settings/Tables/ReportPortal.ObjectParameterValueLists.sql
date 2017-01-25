CREATE TABLE [ReportPortal].[ObjectParameterValueLists]
(
[DataSourceSqlScript] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSourceSqlScriptTypeID] [tinyint] NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DescrFieldDataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescrFieldName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdFieldDataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdFieldName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptParamValueListGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectParameterValueLists_RptParamValueListGuid] DEFAULT (newid()),
[RptParamValueListID] [smallint] NOT NULL IDENTITY(1, 1),
[TypicalParamName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypicalParamDataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectParameterValueLists] ADD CONSTRAINT [PK_ReportPortal_ObjectParameterValueLists] PRIMARY KEY CLUSTERED  ([RptParamValueListID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_ObjectParameterValueLists_RptParamValueListGuid] ON [ReportPortal].[ObjectParameterValueLists] ([RptParamValueListGuid]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectParameterValueLists] ADD CONSTRAINT [FK_ReportPortal_ObjectParameterValueLists_DataSourceSqlScriptTypes] FOREIGN KEY ([DataSourceSqlScriptTypeID]) REFERENCES [ReportPortal].[DataSourceSqlScriptTypes] ([DataSourceSqlScriptTypeID])
GO
