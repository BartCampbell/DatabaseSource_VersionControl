CREATE TABLE [Log].[PCR_ClinicalConditions]
(
[BatchID] [int] NULL,
[CodeID] [int] NULL,
[CountCodes] [int] NULL,
[DataRunID] [int] NULL,
[DataSetID] [int] NULL,
[DSClaimCodeID] [bigint] NULL,
[DSClaimID] [bigint] NULL,
[DSClaimLineID] [bigint] NULL,
[DSEntityID] [bigint] NOT NULL,
[DSMemberID] [bigint] NOT NULL,
[EvalTypeID] [tinyint] NULL,
[HClinCond] [smallint] NOT NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_PCR_ClinicalConditions_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PCR_ClinicalConditions_LogUser] DEFAULT (suser_sname()),
[MeasureID] [int] NOT NULL CONSTRAINT [DF_PCR_ClinicalConditions_MeasureID] DEFAULT ((0)),
[OwnerID] [int] NULL,
[SourceRowGuid] [uniqueidentifier] NULL,
[SourceRowID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[PCR_ClinicalConditions] ADD CONSTRAINT [PK_Log_PCR_ClinicalConditions] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_PCR_ClinicalConditions_BatchID] ON [Log].[PCR_ClinicalConditions] ([BatchID], [DataRunID], [DataSetID], [DSMemberID], [LogID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Log_PCR_ClinicalConditions_DSMemberID] ON [Log].[PCR_ClinicalConditions] ([DSMemberID], [MeasureID], [DataRunID], [BatchID], [DataSetID], [OwnerID]) ON [PRIMARY]
GO
