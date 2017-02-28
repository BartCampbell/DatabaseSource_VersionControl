CREATE TABLE [dbo].[Chris_MAO004]
(
[InboundFileName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportId] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAContractId] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterICN] [varchar] (44) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterTypeSwitch] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalEncounterICN] [varchar] (44) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanSubmissionDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessingDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BeginDateOfService] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndDateOfService] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RestOfDetailRecordFromPosition159] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
