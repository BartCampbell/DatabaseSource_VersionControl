CREATE TABLE [dbo].[MedicalRecordFPCGA]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[GestationalAge] [int] NOT NULL,
[GestationalSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryDate] [datetime] NULL,
[LMPDate] [datetime] NULL,
[CalculatedEDD] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordFPCGA_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordfpcga_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordFPCGA] ADD CONSTRAINT [PK_MedicalRecordFPCGA] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordFPCGA] ADD CONSTRAINT [FK_MedicalRecordFPCGA_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordFPCGA] ADD CONSTRAINT [FK_MedicalRecordFPCGA_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
