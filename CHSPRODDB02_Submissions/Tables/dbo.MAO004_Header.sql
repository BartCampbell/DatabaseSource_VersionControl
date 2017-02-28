CREATE TABLE [dbo].[MAO004_Header]
(
[HeaderId] [int] NOT NULL IDENTITY(1, 1),
[InboundFileName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDateTime] [datetime] NOT NULL,
[RecordType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportId] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAContractId] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDesc] [varchar] (53) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmissionFileType] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO004_Header] ADD CONSTRAINT [PK_MAO004_Header] PRIMARY KEY CLUSTERED  ([HeaderId]) ON [PRIMARY]
GO
