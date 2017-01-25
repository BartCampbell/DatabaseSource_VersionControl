CREATE TABLE [dbo].[MedicalRecordRISKDiag]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[CodeTypeID] [smallint] NOT NULL,
[Code] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL,
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordRISKDiag] ADD CONSTRAINT [PK_MedicalRecordRISKDiag] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordRISKDiag] ADD CONSTRAINT [FK_MedicalRecordRISKDiag_ClaimCodeTypes] FOREIGN KEY ([CodeTypeID]) REFERENCES [dbo].[ClaimCodeTypes] ([CodeTypeID])
GO
ALTER TABLE [dbo].[MedicalRecordRISKDiag] ADD CONSTRAINT [FK_MedicalRecordRISKDiag_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordRISKDiag] ADD CONSTRAINT [FK_MedicalRecordRISKDiag_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
