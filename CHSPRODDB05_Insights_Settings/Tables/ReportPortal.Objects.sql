CREATE TABLE [ReportPortal].[Objects]
(
[BitAudience] [bigint] NOT NULL CONSTRAINT [DF_Objects_BitAudience] DEFAULT ((0)),
[Blurb] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsSensitive] [bit] NOT NULL CONSTRAINT [DF_Objects_IsSensitive] DEFAULT ((0)),
[ObjectName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptObjGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Objects_RptObjGuid] DEFAULT (newid()),
[RptObjID] [smallint] NOT NULL IDENTITY(1, 1),
[RptObjTypeID] [tinyint] NOT NULL,
[RptRelPath] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UrlSeg] AS (CONVERT([varchar](512),lower(('/'+isnull(replace([RptRelPath],'/','-'),''))+replace(replace(replace([ObjectName],'&','and'),' - ','-'),' ','-')),(0))) PERSISTED
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Objects] ADD CONSTRAINT [PK_ReportPortal_Objects] PRIMARY KEY CLUSTERED  ([RptObjID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Objects_ObjectName] ON [ReportPortal].[Objects] ([ObjectName], [RptRelPath]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Objects] ON [ReportPortal].[Objects] ([RptObjGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ReportPortal_Objects_UrlSeg] ON [ReportPortal].[Objects] ([UrlSeg]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[Objects] ADD CONSTRAINT [FK_ReportPortal_Objects_ObjectTypes] FOREIGN KEY ([RptObjTypeID]) REFERENCES [ReportPortal].[ObjectTypes] ([RptObjTypeID])
GO
