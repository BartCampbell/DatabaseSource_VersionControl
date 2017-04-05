CREATE TABLE [Provider].[Providers]
(
[BitSpecialties] [bigint] NOT NULL CONSTRAINT [DF_Providers_BitSpecialties] DEFAULT ((0)),
[DataSetID] [int] NOT NULL,
[DataSourceID] [int] NOT NULL CONSTRAINT [DF__Providers__DataS__160DE3A3] DEFAULT ((-1)),
[DSProviderID] [bigint] NOT NULL IDENTITY(1, 1),
[IhdsProviderID] [int] NULL,
[IsContracted] [bit] NOT NULL CONSTRAINT [DF_Providers_IsContracted] DEFAULT ((0)),
[ProviderID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Provider].[Providers] ADD CONSTRAINT [PK_Providers] PRIMARY KEY CLUSTERED  ([DSProviderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Providers_DataSetID] ON [Provider].[Providers] ([DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Providers_IhdsProviderID] ON [Provider].[Providers] ([IhdsProviderID], [DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Providers_ProviderID] ON [Provider].[Providers] ([ProviderID], [DataSetID]) ON [PRIMARY]
GO
