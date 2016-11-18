CREATE TABLE [dbo].[USER_RELATION]
(
[RELATIONID] [numeric] (19, 0) NOT NULL,
[SOURCEUSER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[TARGETUSER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[RELATIONNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CREATIONDATE] [datetime] NOT NULL,
[LASTMODDATE] [datetime] NOT NULL,
[CREATOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[LASTMODIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [PK__USER_REL__E909023EF99F7904] PRIMARY KEY CLUSTERED  ([RELATIONID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2u_cdate_idx] ON [dbo].[USER_RELATION] ([CREATIONDATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [r_u2u_creator_idx] ON [dbo].[USER_RELATION] ([CREATOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [r_u2u_lastmodifier_idx] ON [dbo].[USER_RELATION] ([LASTMODIFIER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2u_relationname_idx] ON [dbo].[USER_RELATION] ([RELATIONNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2u_sourceuser_idx] ON [dbo].[USER_RELATION] ([SOURCEUSER]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [u2u_relation_unique] UNIQUE NONCLUSTERED  ([SOURCEUSER], [TARGETUSER], [RELATIONNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2u_targetuser_idx] ON [dbo].[USER_RELATION] ([TARGETUSER]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [FK_RELATION_U2USUSER] FOREIGN KEY ([SOURCEUSER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [FK_RELATION_U2UTUSER] FOREIGN KEY ([TARGETUSER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [FK_U2URELATION_CREATOR] FOREIGN KEY ([CREATOR]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USER_RELATION] ADD CONSTRAINT [FK_U2URELATION_LASTMODIFIER] FOREIGN KEY ([LASTMODIFIER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
