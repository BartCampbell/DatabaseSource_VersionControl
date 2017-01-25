CREATE TABLE [CGF].[EnrollmentGroups]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollGroupGuid] [uniqueidentifier] NOT NULL,
[EnrollGroupID] [int] NOT NULL,
[GroupNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL
) ON [PRIMARY]
GO
