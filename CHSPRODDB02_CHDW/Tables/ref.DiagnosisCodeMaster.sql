CREATE TABLE [ref].[DiagnosisCodeMaster]
(
[DXCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXShortDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXLongDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveFrom] [datetime] NULL,
[EffectiveTo] [datetime] NULL,
[ICDVersion] [int] NULL,
[DiagnosisCodeMasterID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[DiagnosisCodeMaster] ADD CONSTRAINT [PK_DiagnosisCodeMaster] PRIMARY KEY CLUSTERED  ([DiagnosisCodeMasterID]) ON [PRIMARY]
GO
