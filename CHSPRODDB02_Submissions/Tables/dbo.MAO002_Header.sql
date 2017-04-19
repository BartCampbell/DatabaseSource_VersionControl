CREATE TABLE [dbo].[MAO002_Header]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[RecordType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionDate] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmissionInterchangeNumber] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordType2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmissionFileType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_MAO002_Header_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO002_Header] ADD CONSTRAINT [PK_MAO002_Header] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
