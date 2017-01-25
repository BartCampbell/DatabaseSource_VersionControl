CREATE TABLE [ReportPortal].[ObjectInfo]
(
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ObjectInfo_CreatedDate] DEFAULT (getdate()),
[Info] [xml] NOT NULL,
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF_ObjectInfo_LastUpdatedDate] DEFAULT (getdate()),
[RptObjID] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectInfo] ADD CONSTRAINT [PK_ReportPortal_ObjectInfo] PRIMARY KEY CLUSTERED  ([RptObjID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectInfo] ADD CONSTRAINT [FK_ReportPortal_ObjectInfo_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
