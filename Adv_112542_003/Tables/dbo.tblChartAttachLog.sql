CREATE TABLE [dbo].[tblChartAttachLog]
(
[Suspect_PK] [bigint] NOT NULL,
[User_PK] [int] NULL,
[FileID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PageFrom] [smallint] NULL,
[PageTo] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[IsProcessed] [bit] NULL,
[PagesInPDF] [int] NULL,
[IsAlreadyScanned] [bit] NULL,
[PagesAlreadyScanned] [int] NULL,
[Batch] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblChartAttachLog_1] ON [dbo].[tblChartAttachLog] ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblChartAttachLog] ON [dbo].[tblChartAttachLog] ([User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
