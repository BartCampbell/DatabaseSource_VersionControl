CREATE TABLE [dbo].[MedicalRecordWCCAPCSMOK]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[DocumentationTypeID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCAPCSMOK_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCapcsmok_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSMOK] ADD CONSTRAINT [PK_MedicalRecordWCCAPCSMOK] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSMOK_PursuitEventID] ON [dbo].[MedicalRecordWCCAPCSMOK] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSMOK] ON [dbo].[MedicalRecordWCCAPCSMOK] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSMOK] WITH NOCHECK ADD CONSTRAINT [FK_MedicalRecordWCCAPCSMOK_DropDownValues_WCCDocumentation] FOREIGN KEY ([DocumentationTypeID]) REFERENCES [dbo].[DropDownValues_WCCDocumentation] ([DocumentationTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSMOK] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSMOK_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSMOK] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSMOK_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
