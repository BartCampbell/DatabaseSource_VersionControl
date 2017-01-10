CREATE TABLE [dbo].[YHA_20151218_RAPS]
(
[MEMBER ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member Individual ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SERVICE FROM DT] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SERVICE TO DT] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Page From] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Page To] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REN_TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
