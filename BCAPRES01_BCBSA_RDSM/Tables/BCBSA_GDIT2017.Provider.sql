CREATE TABLE [BCBSA_GDIT2017].[Provider]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowFileID] [int] NULL,
[JobRunTaskFileID] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[ProviderID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMiddleInitial] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNameSuffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderAddress2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCounty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderZipCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderTelephone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFAX] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prescribing] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPA] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltPopID1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AltPopID2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCustom1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCustom2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCustom3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderCustom4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OMEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [BCBSA_GDIT2017_Provider]
GO
CREATE NONCLUSTERED INDEX [idxProvider] ON [BCBSA_GDIT2017].[Provider] ([ProviderID]) ON [BCBSA_GDIT2017_Provider_IDX]
GO
CREATE CLUSTERED INDEX [clidxProviderr] ON [BCBSA_GDIT2017].[Provider] ([RowID]) ON [BCBSA_GDIT2017_Provider]
GO
CREATE STATISTICS [spidxProvider] ON [BCBSA_GDIT2017].[Provider] ([ProviderID])
GO
CREATE STATISTICS [spclidxProviderr] ON [BCBSA_GDIT2017].[Provider] ([RowID])
GO
