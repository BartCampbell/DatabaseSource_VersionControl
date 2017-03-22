CREATE TABLE [dbo].[tblProviderOfficeSubBucket]
(
[ProviderOfficeSubBucket_PK] [tinyint] NOT NULL,
[SubBucket] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsVisible] [bit] NULL,
[sortOrder] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxProviderOfficeSubBucket] ON [dbo].[tblProviderOfficeSubBucket] ([ProviderOfficeSubBucket_PK]) ON [PRIMARY]
GO
