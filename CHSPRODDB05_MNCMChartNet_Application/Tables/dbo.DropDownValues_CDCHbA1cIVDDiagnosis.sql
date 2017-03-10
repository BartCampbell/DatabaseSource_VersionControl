CREATE TABLE [dbo].[DropDownValues_CDCHbA1cIVDDiagnosis]
(
[IVDDiagnosisID] [int] NOT NULL,
[SortKey] [int] NOT NULL CONSTRAINT [DF_DropDownValues_CDCHbA1cIVDDiagnosis_SortKey] DEFAULT ((0)),
[Description] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_CDCHbA1cIVDDiagnosis] ADD CONSTRAINT [PK_DropDownValues_CDCHbA1cIVDDiagnosis] PRIMARY KEY CLUSTERED  ([IVDDiagnosisID]) ON [PRIMARY]
GO
