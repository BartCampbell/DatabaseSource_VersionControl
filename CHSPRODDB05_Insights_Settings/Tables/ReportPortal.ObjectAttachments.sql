CREATE TABLE [ReportPortal].[ObjectAttachments]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MimeType] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RptAttachID] [smallint] NOT NULL IDENTITY(1, 1),
[RptObjID] [smallint] NOT NULL,
[Size] [bigint] NOT NULL,
[SortOrder] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectAttachments] ADD CONSTRAINT [PK_ReportPortal_ObjectAttachments] PRIMARY KEY CLUSTERED  ([RptAttachID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectAttachments] WITH NOCHECK ADD CONSTRAINT [FK_ReportPortal_ObjectAttachments_Objects] FOREIGN KEY ([RptObjID]) REFERENCES [ReportPortal].[Objects] ([RptObjID])
GO
