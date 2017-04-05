CREATE TABLE [dbo].[Pharmacy]
(
[PharmacyID] [int] NOT NULL IDENTITY(1, 1),
[Address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEANumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InstanceID] [uniqueidentifier] NULL,
[NABPNumber] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Phone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Pharmacy] ADD CONSTRAINT [actPharmacy_PK] PRIMARY KEY CLUSTERED  ([PharmacyID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_actPharmacy_PK] ON [dbo].[Pharmacy] ([PharmacyID])
GO
