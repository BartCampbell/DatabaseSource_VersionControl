CREATE TABLE [dbo].[AetnaMaineChases_Master]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberIndID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [date] NULL,
[ProviderNPI] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTIN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chase_ID] [int] NULL,
[TINMatch] [int] NULL CONSTRAINT [DF__AetnaMain__TINMa__40106F4B] DEFAULT ((0)),
[AddressMatch] [int] NULL CONSTRAINT [DF__AetnaMain__Addre__41049384] DEFAULT ((0)),
[FacilityName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AetnaMaineChases_Master] ADD CONSTRAINT [UQ__AetnaMai__FBDF78C8B79D6775] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
