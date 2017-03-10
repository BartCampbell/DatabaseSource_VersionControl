CREATE TABLE [dbo].[MedicalRecordWCCAPCSUBS]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[DocumentationTypeID] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCAPCSUBS_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCapcsubs_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSUBS] ADD CONSTRAINT [PK_MedicalRecordWCCAPCSUBS] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSUBS_PursuitEventID] ON [dbo].[MedicalRecordWCCAPCSUBS] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCAPCSUBS] ON [dbo].[MedicalRecordWCCAPCSUBS] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSUBS] WITH NOCHECK ADD CONSTRAINT [FK_MedicalRecordWCCAPCSUBS_DropDownValues_WCCDocumentation] FOREIGN KEY ([DocumentationTypeID]) REFERENCES [dbo].[DropDownValues_WCCDocumentation] ([DocumentationTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSUBS] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSUBS_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCAPCSUBS] ADD CONSTRAINT [FK_MedicalRecordWCCAPCSUBS_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
