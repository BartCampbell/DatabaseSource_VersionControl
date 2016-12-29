CREATE TABLE [dbo].[tblInteraction]
(
[Interaction_PK] [tinyint] NOT NULL IDENTITY(1, 1),
[Interaction] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDisabled] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInteraction] ADD CONSTRAINT [PK__tblInteraction] PRIMARY KEY CLUSTERED  ([Interaction_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
