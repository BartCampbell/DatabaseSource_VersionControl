CREATE TABLE [CGF].[EnrollmentPopulations]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataSetID] [int] NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentID] [int] NULL,
[PopulationGuid] [uniqueidentifier] NOT NULL,
[PopulationID] [int] NOT NULL,
[PopulationNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OwnerID] [int] NOT NULL
) ON [PRIMARY]
GO
