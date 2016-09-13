CREATE TABLE [dbo].[tblProviderOfficeStatus]
(
[Project_PK] [smallint] NOT NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[OfficeIssueStatus] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeStatus] ADD CONSTRAINT [PK_tblProviderOfficeStatus] PRIMARY KEY CLUSTERED  ([Project_PK], [ProviderOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OfficeStatus] ON [dbo].[tblProviderOfficeStatus] ([OfficeIssueStatus]) INCLUDE ([Project_PK], [ProviderOffice_PK]) ON [PRIMARY]
GO
