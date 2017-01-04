CREATE TABLE [dbo].[MAO002_Footer]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RecordType] [int] NULL,
[ReportID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalNumProcessingErrors] [int] NULL,
[TotalNumEncounterLinesAccepted] [int] NULL,
[TotalNumEncounterLinesRejected] [int] NULL,
[TotalNumEncounterLinesSubmitted] [int] NULL,
[TotalNumEncounterRecordsAccepted] [int] NULL,
[TotalNumEncounterRecordsRejected] [int] NULL,
[TotalNumEncounterRecordsSubmitted] [int] NULL,
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_MAO002_Footer_LoadDate] DEFAULT (getdate()),
[RecID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO002_Footer] ADD CONSTRAINT [PK_MAO002_Footer] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
