CREATE TABLE [Member].[EnrollmentPopulations]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSetID] [int] NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentID] [int] NULL,
[PopulationGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EnrollmentPopulations_PopulationGuid] DEFAULT (newid()),
[PopulationID] [int] NOT NULL IDENTITY(1, 1),
[PopulationNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OwnerID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentPopulations] ADD CONSTRAINT [PK_EnrollmentPopulations] PRIMARY KEY CLUSTERED  ([PopulationID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EnrollmentPopulations_Abbrev] ON [Member].[EnrollmentPopulations] ([Abbrev], [OwnerID], [DataSetID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentPopulations_DataSetID] ON [Member].[EnrollmentPopulations] ([DataSetID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentPopulations_OwnerID] ON [Member].[EnrollmentPopulations] ([OwnerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentPopulations_ParentID] ON [Member].[EnrollmentPopulations] ([ParentID]) ON [PRIMARY]
GO
