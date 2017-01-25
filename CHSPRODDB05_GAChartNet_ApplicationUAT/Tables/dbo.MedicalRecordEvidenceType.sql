CREATE TABLE [dbo].[MedicalRecordEvidenceType]
(
[EvidenceTypeKey] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [int] NOT NULL CONSTRAINT [DF_MedicalRecordEvidenceType_SortOrder] DEFAULT ((0)),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordEvidenceType_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordEvidenceType_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordEvidenceType] ADD CONSTRAINT [PK_MedicalEvidenceType] PRIMARY KEY CLUSTERED  ([EvidenceTypeKey]) ON [PRIMARY]
GO
