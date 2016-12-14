CREATE TABLE [dbo].[VIVA_SuspectHICNumber]
(
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxHic] ON [dbo].[VIVA_SuspectHICNumber] ([Member_ID]) ON [PRIMARY]
GO
