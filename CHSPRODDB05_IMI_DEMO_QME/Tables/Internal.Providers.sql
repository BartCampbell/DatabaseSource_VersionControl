CREATE TABLE [Internal].[Providers]
(
[BatchID] [int] NOT NULL,
[BitSpecialties] [bigint] NOT NULL CONSTRAINT [DF_Providers_BitSpecialties] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL,
[DSProviderID] [bigint] NOT NULL,
[IhdsProviderID] [int] NULL,
[ProviderID] [int] NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_Providers_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[Providers] ADD CONSTRAINT [PK_Internal_Providers] PRIMARY KEY CLUSTERED  ([SpId], [DSProviderID], [BatchID]) ON [PRIMARY]
GO
