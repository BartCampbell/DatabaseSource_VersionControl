CREATE TABLE [dbo].[QuickRAPS]
(
[MEMBER ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER TYPE] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE FROM DT] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE TO DT] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN Provider ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Code] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX CODE CATEGORY] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION REASON] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page From] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page To] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_TIN] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
