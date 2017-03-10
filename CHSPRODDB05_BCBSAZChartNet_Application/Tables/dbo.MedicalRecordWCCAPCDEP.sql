CREATE TABLE [dbo].[MedicalRecordWCCAPCDEP]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[DocumentationTypeID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCAPCDEP_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCapcdep_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCDEP] ADD CONSTRAINT [PK_MedicalRecordWCCAPCDEP] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCDEP_PursuitEventID] ON [dbo].[MedicalRecordWCCAPCDEP] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCDEP] ON [dbo].[MedicalRecordWCCAPCDEP] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCDEP] WITH NOCHECK ADD CONSTRAINT [FK_MedicalRecordWCCAPCDEP_DropDownValues_WCCDocumentation] FOREIGN KEY ([DocumentationTypeID]) REFERENCES [dbo].[DropDownValues_WCCDocumentation] ([DocumentationTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCDEP] ADD CONSTRAINT [FK_MedicalRecordWCCAPCDEP_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCDEP] ADD CONSTRAINT [FK_MedicalRecordWCCAPCDEP_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
