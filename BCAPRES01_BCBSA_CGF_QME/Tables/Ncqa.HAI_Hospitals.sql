CREATE TABLE [Ncqa].[HAI_Hospitals]
(
[Address] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[City] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[County] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HospGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_HAI_Hospitals_HospGuid] DEFAULT (newid()),
[HospID] [int] NOT NULL IDENTITY(1, 1),
[HospitalID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[HAI_Hospitals] ADD CONSTRAINT [PK_Ncqa_HAI_Hospitals] PRIMARY KEY CLUSTERED  ([HospID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_HAI_Hospitals] ON [Ncqa].[HAI_Hospitals] ([HospGuid]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Ncqa_HAI_Hospitals_HospitalID] ON [Ncqa].[HAI_Hospitals] ([HospitalID]) ON [PRIMARY]
GO
