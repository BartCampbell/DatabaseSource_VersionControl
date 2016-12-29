CREATE TABLE [dbo].[tblScannedDataPageStatus]
(
[ScannedData_PK] [bigint] NOT NULL,
[User_PK] [smallint] NOT NULL,
[CoderLevel] [tinyint] NOT NULL,
[PageStatus_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScannedDataPageStatus] ADD CONSTRAINT [PK_tblScannedDataPageStatus] PRIMARY KEY CLUSTERED  ([ScannedData_PK], [CoderLevel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScannedDataPageStatus_PageStatus] ON [dbo].[tblScannedDataPageStatus] ([PageStatus_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScannedDataPageStatus_ScannedData] ON [dbo].[tblScannedDataPageStatus] ([ScannedData_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScannedDataPageStatus_User] ON [dbo].[tblScannedDataPageStatus] ([User_PK]) ON [PRIMARY]
GO
