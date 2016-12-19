CREATE TABLE [dbo].[tblProviderOfficeBucket]
(
[ProviderOfficeBucket_PK] [tinyint] NOT NULL,
[Bucket] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[IsVisible] [bit] NULL,
[sortOrder] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProviderOfficeBucket] ADD CONSTRAINT [PK_tblProviderOfficeBucket] PRIMARY KEY CLUSTERED  ([ProviderOfficeBucket_PK]) ON [PRIMARY]
GO
