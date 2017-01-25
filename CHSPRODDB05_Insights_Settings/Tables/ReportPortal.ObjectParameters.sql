CREATE TABLE [ReportPortal].[ObjectParameters]
(
[DefaultValueDescr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasDefaultValue] [bit] NOT NULL CONSTRAINT [DF_ObjectParameters_HasDefault] DEFAULT ((0)),
[ParamDataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParamName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptObjID] [smallint] NOT NULL,
[RptParamGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectParameters_RptParamGuid] DEFAULT (newid()),
[RptParamID] [smallint] NOT NULL IDENTITY(1, 1),
[RptParamValueListID] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectParameters] ADD CONSTRAINT [PK_ReportPortal_ObjectParameters] PRIMARY KEY CLUSTERED  ([RptParamID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_ObjectParameters_RptParamGuid] ON [ReportPortal].[ObjectParameters] ([RptParamGuid]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectParameters] ADD CONSTRAINT [FK_ReportPortal_ObjectParameters_ObjectParameterValueLists] FOREIGN KEY ([RptParamValueListID]) REFERENCES [ReportPortal].[ObjectParameterValueLists] ([RptParamValueListID])
GO
ALTER TABLE [ReportPortal].[ObjectParameters] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_ObjectParameters_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
