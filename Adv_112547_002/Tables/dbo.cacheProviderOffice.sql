CREATE TABLE [dbo].[cacheProviderOffice]
(
[Project_PK] [smallint] NOT NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[charts] [smallint] NULL,
[providers] [smallint] NULL,
[office_status] [tinyint] NULL,
[contacted] [tinyint] NULL,
[scheduled] [smallint] NULL,
[extracted] [smallint] NULL,
[coded] [smallint] NULL,
[contact_num] [tinyint] NULL CONSTRAINT [DF__cacheProv__conta__46D27B73] DEFAULT ((1)),
[schedule_type] [tinyint] NULL,
[follow_up] [date] NULL,
[CNA] [smallint] NULL,
[extracted_count] [smallint] NULL,
[coded_count] [smallint] NULL,
[cna_count] [smallint] NULL,
[dtLastContact] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cacheProviderOffice] ADD CONSTRAINT [PK_cacheProviderOffice] PRIMARY KEY CLUSTERED  ([Project_PK], [ProviderOffice_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_FollowUp] ON [dbo].[cacheProviderOffice] ([follow_up]) INCLUDE ([ProviderOffice_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProviderPKProviderOfficePK] ON [dbo].[cacheProviderOffice] ([Project_PK], [ProviderOffice_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ProviderOfficePK] ON [dbo].[cacheProviderOffice] ([ProviderOffice_PK]) INCLUDE ([dtLastContact], [follow_up]) ON [PRIMARY]
GO
GRANT ALTER ON  [dbo].[cacheProviderOffice] TO [INTERNAL\Paul.Johnson]
GO
GRANT CONTROL ON  [dbo].[cacheProviderOffice] TO [INTERNAL\Paul.Johnson]
GO
GRANT INSERT ON  [dbo].[cacheProviderOffice] TO [INTERNAL\Paul.Johnson]
GO
GRANT DELETE ON  [dbo].[cacheProviderOffice] TO [INTERNAL\Paul.Johnson]
GO
