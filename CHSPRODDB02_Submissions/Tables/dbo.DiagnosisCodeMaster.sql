CREATE TABLE [dbo].[DiagnosisCodeMaster]
(
[DXCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXShortDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXLongDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveFrom] [datetime] NULL,
[EffectiveTo] [datetime] NULL,
[ICDVersion] [int] NULL,
[DiagnosisCodeMasterID] [int] NOT NULL IDENTITY(1, 1),
[ChronicInd] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiagnosisCodeMaster] ADD CONSTRAINT [PK_DiagnosisCodeMaster] PRIMARY KEY CLUSTERED  ([DiagnosisCodeMasterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
