CREATE TABLE [dbo].[mpi_dupe_deleted]
(
[SourceName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceEntityID] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterEntityID] [uniqueidentifier] NULL,
[EntityType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceID] [int] NULL,
[DateDeleted] [datetime] NULL
) ON [PRIMARY]
GO
