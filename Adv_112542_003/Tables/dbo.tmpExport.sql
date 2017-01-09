CREATE TABLE [dbo].[tmpExport]
(
[MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE FROM DT] [date] NULL,
[SERVICE TO DT] [date] NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Page From] [smallint] NULL,
[Page To] [smallint] NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_PK] [int] NULL,
[Suspect_PK] [bigint] NOT NULL,
[ChaseID] [bigint] NULL
) ON [PRIMARY]
GO
