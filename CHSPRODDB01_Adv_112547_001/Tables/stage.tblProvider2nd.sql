CREATE TABLE [stage].[tblProvider2nd]
(
[Provider_PK] [bigint] NOT NULL IDENTITY(1, 1),
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [stage].[tblProvider2nd] ADD CONSTRAINT [PK_tblProvider_1] PRIMARY KEY CLUSTERED  ([Provider_PK]) ON [PRIMARY]
GO
