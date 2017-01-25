CREATE TABLE [ReportPortal].[ObjectAttachmentData]
(
[Data] [varbinary] (max) NOT NULL,
[RptAttachID] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectAttachmentData] ADD CONSTRAINT [PK_ReportPortal.ObjectAttachmentData] PRIMARY KEY CLUSTERED  ([RptAttachID]) ON [PRIMARY]
GO
ALTER TABLE [ReportPortal].[ObjectAttachmentData] ADD CONSTRAINT [FK_ReportPortal_ObjectAttachmentData_ObjectAttachments] FOREIGN KEY ([RptAttachID]) REFERENCES [ReportPortal].[ObjectAttachments] ([RptAttachID])
GO
