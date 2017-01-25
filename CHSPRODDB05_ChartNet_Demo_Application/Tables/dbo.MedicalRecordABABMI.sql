CREATE TABLE [dbo].[MedicalRecordABABMI]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[BMIValue] [decimal] (6, 2) NOT NULL,
[BMIPercentile] [decimal] (6, 2) NOT NULL,
[Height] [decimal] (6, 2) NOT NULL,
[Weight] [decimal] (6, 2) NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordABABMI_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordABABMI_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlottedOnAgeGrowthChart] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Plott__0AFD888E] DEFAULT ((0)),
[BMIPercentileGT99] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__BMIPe__737B04B8] DEFAULT ((0)),
[BMIPercentileLT1] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__BMIPe__746F28F1] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordABABMI] ADD CONSTRAINT [PK_MedicalRecordABABMI] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordABABMI_PursuitEventID] ON [dbo].[MedicalRecordABABMI] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordABABMI] ON [dbo].[MedicalRecordABABMI] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordABABMI] ADD CONSTRAINT [FK_MedicalRecordABABMI_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordABABMI] ADD CONSTRAINT [FK_MedicalRecordABABMI_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
