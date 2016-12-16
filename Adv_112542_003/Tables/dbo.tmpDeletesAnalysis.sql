CREATE TABLE [dbo].[tmpDeletesAnalysis]
(
[MEMBER ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member Individual ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Claim ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROVIDER TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SERVICE FROM DT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SERVICE TO DT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REN Provider ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DX CODE CATEGORY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD CODE DISPOSITION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ICD CODE DISPOSITION REASON] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Page From] [float] NULL,
[Page To] [float] NULL,
[REN_TIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REN_PIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CHART NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Visionary Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Column1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Column12] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Visionary Final Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
