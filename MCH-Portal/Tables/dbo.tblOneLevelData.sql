CREATE TABLE [dbo].[tblOneLevelData]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
[encounter_pk] [bigint] NOT NULL,
[CPT_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[oneCheck_pk] [smallint] NULL,
[oneCheck_score] [smallint] NULL
) ON [PRIMARY]
GO
