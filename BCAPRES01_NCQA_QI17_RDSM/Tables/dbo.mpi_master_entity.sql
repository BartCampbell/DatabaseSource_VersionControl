CREATE TABLE [dbo].[mpi_master_entity]
(
[MasterEntityID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_mpi_master_entity_MasterEntityID] DEFAULT (newid()),
[EntityTypeID] [uniqueidentifier] NOT NULL,
[DateCreated] [datetime] NULL,
[SourceID] [uniqueidentifier] NULL,
[SourceDataLoadID] [uniqueidentifier] NULL,
[SourceEntityID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mpi_master_entity] ADD CONSTRAINT [PK_mpi_master_entity] PRIMARY KEY CLUSTERED  ([SourceEntityID], [EntityTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_mpi_master_entity] ON [dbo].[mpi_master_entity] ([MasterEntityID]) ON [PRIMARY]
GO
