CREATE TABLE [dbo].[WellCareSuspectProvider]
(
[Suspect_PK] [bigint] NOT NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
