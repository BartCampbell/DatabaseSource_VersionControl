CREATE TABLE [Member].[EnrollmentGroups]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollGroupGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_EnrollmentGroups_EnrollGroupGuid] DEFAULT (newid()),
[EnrollGroupID] [int] NOT NULL IDENTITY(1, 1),
[GroupNum] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayerID] [smallint] NOT NULL,
[PopulationID] [int] NOT NULL,
[Priority] [smallint] NOT NULL CONSTRAINT [DF_EnrollmentGroups_Priority] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Member].[EnrollmentGroups] ADD CONSTRAINT [PK_EnrollmentGroups] PRIMARY KEY CLUSTERED  ([EnrollGroupID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EnrollmentGroups_PayerID] ON [Member].[EnrollmentGroups] ([PayerID]) ON [PRIMARY]
GO
