CREATE TABLE [dbo].[tmpDeletesAnalysis]
(
[MEMBER ID] [sys].[sysname] NULL,
[Member Individual ID] [sys].[sysname] NULL,
[Claim ID] [sys].[sysname] NULL,
[PROVIDER TYPE] [sys].[sysname] NULL,
[SERVICE FROM DT] [sys].[sysname] NULL,
[SERVICE TO DT] [sys].[sysname] NULL,
[REN Provider ID] [sys].[sysname] NULL,
[ICD Code] [sys].[sysname] NULL,
[DX CODE CATEGORY] [sys].[sysname] NULL,
[ICD CODE DISPOSITION] [sys].[sysname] NULL,
[ICD CODE DISPOSITION REASON] [sys].[sysname] NULL,
[Page From] [float] NULL,
[Page To] [float] NULL,
[REN_TIN] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [sys].[sysname] NULL,
[Visionary Comments] [sys].[sysname] NULL,
[Login] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column1] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column12] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visionary Final Comments] [sys].[sysname] NULL
) ON [PRIMARY]
GO
