CREATE TABLE [ReportPortal].[ObjectTypes]
(
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptObjTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectTypes_RptObjTypeGuid] DEFAULT (newid()),
[RptObjTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectTypes] ADD CONSTRAINT [PK_ReportPortal_ObjectTypes] PRIMARY KEY CLUSTERED  ([RptObjTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_ObjectTypes] ON [ReportPortal].[ObjectTypes] ([RptObjTypeGuid]) ON [PRIMARY]
GO
