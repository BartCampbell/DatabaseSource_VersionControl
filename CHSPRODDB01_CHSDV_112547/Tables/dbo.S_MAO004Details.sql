CREATE TABLE [dbo].[S_MAO004Details]
(
[S_MAO004Details_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_MAO004Record_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportID] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicareAdvantageContractID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Beneficiary HICN] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterICN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterTypeSwitch] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICNOfEncounterLinkedTo] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowedDisallowedStatusOfEncounterLinkedTo] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterSubmissionDate] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FromDateofService] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThroughDateOfService] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowedDisallowedflag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowedDisallowedReasonCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosesICD] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddOrDeleteFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiagnosisCodes&Delimiters&AddDeleteFlagsFor37Diagnoses] [varchar] (370) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MAO004Details] ADD CONSTRAINT [PK_S_MAO004Details] PRIMARY KEY CLUSTERED  ([S_MAO004Details_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_S_MAO004Details_34_1581248688__K21_K23] ON [dbo].[S_MAO004Details] ([HashDiff], [RecordEndDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_S_MAO004Details_34_1581248688__K23] ON [dbo].[S_MAO004Details] ([RecordEndDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_S_MAO004Details_34_1581248688__K23_K21] ON [dbo].[S_MAO004Details] ([RecordEndDate], [HashDiff]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1581248688_14_23_21] ON [dbo].[S_MAO004Details] ([ClaimType], [RecordEndDate], [HashDiff])
GO
ALTER TABLE [dbo].[S_MAO004Details] ADD CONSTRAINT [FK_H_MAO004Record_RK1] FOREIGN KEY ([H_MAO004Record_RK]) REFERENCES [dbo].[H_MAO004Record] ([H_MAO004Record_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
