CREATE TABLE [Provider].[ProviderSpecialties]
(
[DataSetID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[SpecialtyID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Provider].[ProviderSpecialties] ADD CONSTRAINT [PK_ProviderSpecialties] PRIMARY KEY CLUSTERED  ([DSProviderID], [SpecialtyID]) ON [PRIMARY]
GO
