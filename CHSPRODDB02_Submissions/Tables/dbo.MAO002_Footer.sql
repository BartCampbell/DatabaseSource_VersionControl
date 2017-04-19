CREATE TABLE [dbo].[MAO002_Footer]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RecordType] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumProcessingErrors] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterLinesAccepted] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterLinesRejected] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterLinesSubmitted] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterRecordsAccepted] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterRecordsRejected] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumEncounterRecordsSubmitted] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_MAO002_Footer_LoadDate] DEFAULT (getdate()),
[RecID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO002_Footer] ADD CONSTRAINT [PK_MAO002_Footer] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
