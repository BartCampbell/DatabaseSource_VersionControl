CREATE TABLE [Log].[Reports]
(
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SrcObjectID] [smallint] NOT NULL,
[SrcReportGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Reports_SrcReportGuid] DEFAULT (newid()),
[SrcReportID] [smallint] NOT NULL IDENTITY(1, 1),
[SsrsUrl] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[Reports] ADD CONSTRAINT [PK_Log_Reports] PRIMARY KEY CLUSTERED  ([SrcReportID]) ON [PRIMARY]
GO
