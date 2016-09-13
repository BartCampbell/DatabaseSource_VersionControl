CREATE TABLE [dbo].[tblExtractionQueueAttachLog]
(
[ExtractionQueueAttachLog_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Suspect_PK] [bigint] NOT NULL,
[ExtractionQueue_PK] [int] NOT NULL,
[User_PK] [int] NOT NULL,
[PageFrom] [smallint] NOT NULL,
[PageTo] [smallint] NOT NULL,
[dtInsert] [smalldatetime] NOT NULL,
[IsProcessed] [bit] NULL,
[PagesInPDF] [int] NULL,
[PagesAlreadyScanned] [int] NULL,
[PagesScanned] [int] NULL,
[IsInvoice] [bit] NULL,
[ProviderOfficeInvoice_PK] [int] NULL,
[dtProcessed] [smalldatetime] NULL,
[IsCNA] [tinyint] NULL,
[IsDuplicate] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblExtractionQueueAttachLog] ADD CONSTRAINT [PK_tblExtractionQueueAttachLog] PRIMARY KEY CLUSTERED  ([ExtractionQueueAttachLog_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueueAttachLogID] ON [dbo].[tblExtractionQueueAttachLog] ([ExtractionQueue_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueueAttachLogInvoice] ON [dbo].[tblExtractionQueueAttachLog] ([ProviderOfficeInvoice_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueueAttachLogSuspect] ON [dbo].[tblExtractionQueueAttachLog] ([Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblExtractionQueueAttachLogUser] ON [dbo].[tblExtractionQueueAttachLog] ([User_PK]) ON [PRIMARY]
GO
