CREATE TABLE [Ncqa].[PCR_ClinicalConditions]
(
[ClinCond] [smallint] NOT NULL,
[ClinCondGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PCR_ClinicalConditions_ClinCondGuid] DEFAULT (newid()),
[ClinCondID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NULL,
[CodeTypeID] [tinyint] NOT NULL,
[EvalTypeID] [tinyint] NOT NULL,
[MeasureSetID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PCR_ClinicalConditions] ADD CONSTRAINT [PK_PCR_ClinicalConditions] PRIMARY KEY CLUSTERED  ([ClinCondID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PCR_ClinicalConditions_ClinCondGuid] ON [Ncqa].[PCR_ClinicalConditions] ([ClinCondGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PCR_ClinicalConditions_Codes] ON [Ncqa].[PCR_ClinicalConditions] ([Code], [CodeTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PCR_ClinicalConditions] ON [Ncqa].[PCR_ClinicalConditions] ([MeasureSetID], [EvalTypeID], [Code], [CodeTypeID], [ClinCond]) INCLUDE ([CodeID]) ON [PRIMARY]
GO
