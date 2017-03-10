CREATE TABLE [dbo].[MedicalRecordWCCAPCSA]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[DocumentationTypeID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCAPCSA_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCapcsa_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSA] ADD CONSTRAINT [PK_MedicalRecordWCCAPCSA] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSA_PursuitEventID] ON [dbo].[MedicalRecordWCCAPCSA] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSA] ON [dbo].[MedicalRecordWCCAPCSA] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSA] WITH NOCHECK ADD CONSTRAINT [FK_MedicalRecordWCCAPCSA_DropDownValues_WCCDocumentation] FOREIGN KEY ([DocumentationTypeID]) REFERENCES [dbo].[DropDownValues_WCCDocumentation] ([DocumentationTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSA] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSA_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSA] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSA_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
