CREATE TABLE [x12].[RefRegistry]
(
[RefRegistryID] [int] NOT NULL IDENTITY(1, 1),
[TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistrySetID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryGrpMajor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegistryGrpMinor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [x12].[RefRegistry] ADD CONSTRAINT [PK_RefRegistry] PRIMARY KEY CLUSTERED  ([RefRegistryID]) ON [PRIMARY]
GO
