CREATE TABLE [dbo].[MedicalRecordWCCBMI]
(
[MedicalRecordKey] [int] NOT NULL IDENTITY(1, 1),
[PursuitID] [int] NOT NULL,
[PursuitEventID] [int] NOT NULL,
[ServiceDate] [datetime] NOT NULL,
[BMIValue] [decimal] (6, 2) NOT NULL,
[BMIPercentile] [decimal] (6, 2) NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCBMI_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_MedicalRecordWCCBMI_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsWeightDocumentedSameRecord] [bit] NULL,
[IsHeightDocumentedSameRecord] [bit] NULL,
[WeightValueFromRecord] [decimal] (6, 2) NULL,
[HeightValueFromRecord] [decimal] (6, 2) NULL,
[PlottedOnAgeGrowthChart] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__Plott__0BF1ACC7] DEFAULT ((0)),
[BMIPercentileGT99] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__BMIPe__76577163] DEFAULT ((0)),
[BMIPercentileLT1] [bit] NOT NULL CONSTRAINT [DF__MedicalRe__BMIPe__774B959C] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCBMI] ADD CONSTRAINT [PK_MedicalRecordWCCBMI] PRIMARY KEY CLUSTERED  ([MedicalRecordKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCBMI_PursuitEventID] ON [dbo].[MedicalRecordWCCBMI] ([PursuitEventID], [ServiceDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MedicalRecordWCCBMI] ON [dbo].[MedicalRecordWCCBMI] ([PursuitID], [ServiceDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MedicalRecordWCCBMI] ADD CONSTRAINT [FK_MedicalRecordWCCBMI_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
ALTER TABLE [dbo].[MedicalRecordWCCBMI] ADD CONSTRAINT [FK_MedicalRecordWCCBMI_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
