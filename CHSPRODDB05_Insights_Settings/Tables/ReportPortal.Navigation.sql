CREATE TABLE [ReportPortal].[Navigation]
(
[ChildID] [smallint] NOT NULL,
[RptNavID] [smallint] NOT NULL IDENTITY(1, 1),
[RptObjID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Navigation] ADD CONSTRAINT [PK_Navigation] PRIMARY KEY CLUSTERED  ([RptNavID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Navigation] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_Navigation_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
ALTER TABLE [ReportPortal].[Navigation] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_Navigation_Objects_ChildID] FOREIGN KEY ([ChildID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
