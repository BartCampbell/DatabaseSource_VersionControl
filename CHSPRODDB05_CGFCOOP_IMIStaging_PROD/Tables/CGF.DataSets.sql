CREATE TABLE [CGF].[DataSets]
(
[CountClaimCodes] [int] NULL,
[CountClaimLines] [int] NULL,
[CountClaims] [int] NULL,
[CountEnrollment] [int] NULL,
[CountMemberAttribs] [int] NULL,
[CountMembers] [int] NULL,
[CountProviders] [int] NULL,
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedSpId] [int] NOT NULL,
[DataSetGuid] [uniqueidentifier] NOT NULL,
[DataSetID] [int] NOT NULL,
[DefaultIhdsProviderID] [int] NULL,
[EngineGuid] [uniqueidentifier] NOT NULL,
[OwnerID] [int] NOT NULL,
[SourceGuid] [uniqueidentifier] NULL,
[DataSource] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSourceGuid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataSets] ON [CGF].[DataSets] ([DataSetGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_DataSets] ON [CGF].[DataSets] ([DataSetGuid])
GO
