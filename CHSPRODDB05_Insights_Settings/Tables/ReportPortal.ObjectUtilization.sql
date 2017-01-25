CREATE TABLE [ReportPortal].[ObjectUtilization]
(
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ObjectUtilization_CreatedDate] DEFAULT (getdate()),
[Params] [xml] NOT NULL,
[PrincipalID] [smallint] NOT NULL,
[RptObjUtilID] [bigint] NOT NULL IDENTITY(1, 1),
[RptObjID] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectUtilization] ADD CONSTRAINT [PK_ReporPortal_ObjectUtilization] PRIMARY KEY CLUSTERED  ([RptObjUtilID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_ObjectUtilization_PrincipalID] ON [ReportPortal].[ObjectUtilization] ([PrincipalID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportPortal_ObjectUtilization_RptObjID] ON [ReportPortal].[ObjectUtilization] ([RptObjID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectUtilization] ADD CONSTRAINT [FK_ReportPortal_ObjectUtilization_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
ALTER TABLE [ReportPortal].[ObjectUtilization] ADD CONSTRAINT [FK_ReportPortal_ObjectUtilization_SecurityPrincipals] FOREIGN KEY ([PrincipalID]) REFERENCES [ReportPortal].[SecurityPrincipals] ([PrincipalID])
GO
