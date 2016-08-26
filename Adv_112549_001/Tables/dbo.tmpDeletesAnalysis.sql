CREATE TABLE [dbo].[tmpDeletesAnalysis]
(
[MEMBER ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE FROM DT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE TO DT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN Provider ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX CODE CATEGORY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION REASON] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page From] [float] NULL,
[Page To] [float] NULL,
[REN_TIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visionary Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column12] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visionary Final Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
