CREATE TABLE [Batch].[DataSets]
(
[CountClaimCodes] [int] NULL,
[CountClaimLines] [int] NULL,
[CountClaims] [int] NULL,
[CountEnrollment] [int] NULL,
[CountMemberAttribs] [int] NULL,
[CountMembers] [int] NULL,
[CountProviders] [int] NULL,
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DataSets_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DataSets_CreatedDate] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_DataSets_CreatedSpId] DEFAULT (@@spid),
[DataSetGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataSets_DataSetGuid] DEFAULT (newid()),
[DataSetID] [int] NOT NULL IDENTITY(1, 1),
[DefaultIhdsProviderID] [int] NULL,
[EngineGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataSets_EngineGuid] DEFAULT ([Engine].[GetEngineGuid]()),
[IsPurged] [bit] NOT NULL CONSTRAINT [DF_DataSets_IsPurged] DEFAULT ((0)),
[OwnerID] [int] NOT NULL,
[PurgedDate] [datetime] NULL,
[SourceGuid] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataSets] ADD CONSTRAINT [PK_DataSets] PRIMARY KEY CLUSTERED  ([DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DataSets_DataSetGuid] ON [Batch].[DataSets] ([DataSetGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataSets_OwnerID] ON [Batch].[DataSets] ([OwnerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DataSets_SourceGuid] ON [Batch].[DataSets] ([SourceGuid]) WHERE ([SourceGuid] IS NOT NULL) ON [PRIMARY]
GO
