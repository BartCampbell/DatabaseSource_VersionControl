CREATE TABLE [dbo].[MedicalRecordEvidence]
(
[EvidenceKey] [int] NOT NULL IDENTITY(1, 1),
[EvidenceTypeKey] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortKey] [int] NULL CONSTRAINT [DF_MedicalRecordEvidence_SortKey] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordEvidence_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordevidence_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnabledOnWebsite] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Enabl__00750D23] DEFAULT ((1)),
[MeasureComponentID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordEvidence] ADD CONSTRAINT [PK_MedicalRecordEvidence] PRIMARY KEY CLUSTERED  ([EvidenceKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordEvidence] ADD CONSTRAINT [FK_MedicalRecordEvidence_MedicalRecordEvidenceType] FOREIGN KEY ([EvidenceTypeKey]) REFERENCES [dbo].[MedicalRecordEvidenceType] ([EvidenceTypeKey])
GO
