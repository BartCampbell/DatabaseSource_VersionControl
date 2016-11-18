CREATE TABLE [dbo].[AetnaExportHistory]
(
[MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICE FROM DT] [datetime] NULL,
[SERVICE TO DT] [datetime] NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX CODE CATEGORY] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Page From] [smallint] NULL,
[Page To] [smallint] NULL,
[REN_TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [varchar] (104) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtractFileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AetnaExportHistoryID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AetnaExportHistory] ADD CONSTRAINT [PK_AetnaExportHistory] PRIMARY KEY CLUSTERED  ([AetnaExportHistoryID]) ON [PRIMARY]
GO
