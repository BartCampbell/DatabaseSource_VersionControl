CREATE TABLE [dbo].[tblOneLevelText]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
[encounter_pk] [bigint] NULL,
[text_data] [varchar] (550) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpt_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
