CREATE TABLE [dbo].[tblPoolBucket]
(
[Pool_PK] [smallint] NOT NULL,
[ProviderOfficeBucket_PK] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPoolBucket] ADD CONSTRAINT [PK_tblPoolBucket] PRIMARY KEY CLUSTERED  ([Pool_PK], [ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
