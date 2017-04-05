CREATE TABLE [Internal].[ProviderSpecialties]
(
[BatchID] [int] NOT NULL,
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[SpecialtyID] [smallint] NOT NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_ProviderSpecialties_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[ProviderSpecialties] ADD CONSTRAINT [PK_Internal_ProviderSpecialties] PRIMARY KEY CLUSTERED  ([SpId], [DSProviderID], [SpecialtyID]) ON [PRIMARY]
GO
