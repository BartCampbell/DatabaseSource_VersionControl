CREATE TABLE [dbo].[tblProviderOfficeMergeLog]
(
[ProviderOffice_PK] [bigint] NOT NULL,
[Provider_PK] [bigint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeMergeLog] ADD CONSTRAINT [PK_tblProviderOfficeMergeLog] PRIMARY KEY CLUSTERED  ([ProviderOffice_PK], [Provider_PK], [Suspect_PK]) ON [PRIMARY]
GO
