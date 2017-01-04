CREATE TABLE [dim].[ProviderOffice]
(
[ProviderOfficeID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[CentauriProviderOfficeID] [int] NOT NULL,
[CentauriProviderID] [int] NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderOffice_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderOffice_LastUpdate] DEFAULT (getdate()),
[OfficeLocationID] [int] NULL,
[OfficeContactID] [int] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [PK_ProviderOffice] PRIMARY KEY CLUSTERED  ([ProviderOfficeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CPI] ON [dim].[ProviderOffice] ([CentauriProviderOfficeID]) INCLUDE ([ProviderID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [FK_OfficeContact_ProviderOffice] FOREIGN KEY ([OfficeContactID]) REFERENCES [dim].[OfficeContact] ([OfficeContactID])
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [FK_OfficeLocation_ProviderOffice] FOREIGN KEY ([OfficeLocationID]) REFERENCES [dim].[OfficeLocation] ([OfficeLocationID])
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [FK_ProviderOffice_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
