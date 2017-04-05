CREATE TABLE [Log].[ReportUsage]
(
[BeginTime] [datetime] NOT NULL,
[CountRecords] [int] NOT NULL,
[EndTime] [datetime] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogDate] [datetime] NOT NULL CONSTRAINT [DF_ReportUsage_LogDate] DEFAULT (getdate()),
[Parameters] [xml] NULL,
[SrcReportID] [smallint] NOT NULL,
[UserName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ReportUsage_UserName] DEFAULT (suser_sname())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Log].[ReportUsage] ADD CONSTRAINT [PK_Log_ReportUsage] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
