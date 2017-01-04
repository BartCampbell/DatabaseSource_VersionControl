CREATE TABLE [dbo].[MAO002_Detail]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RecordType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlanID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterLineNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncounterStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_MAO002_Detail_LoadDate] DEFAULT (getdate()),
[RecID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAO002_Detail] ADD CONSTRAINT [PK_MAO002_Detail] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
