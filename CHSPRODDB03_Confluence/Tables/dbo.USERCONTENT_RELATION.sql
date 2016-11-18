CREATE TABLE [dbo].[USERCONTENT_RELATION]
(
[RELATIONID] [numeric] (19, 0) NOT NULL,
[TARGETCONTENTID] [numeric] (19, 0) NOT NULL,
[SOURCEUSER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[TARGETTYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[RELATIONNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CREATIONDATE] [datetime] NOT NULL,
[LASTMODDATE] [datetime] NOT NULL,
[CREATOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[LASTMODIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [PK__USERCONT__E909023ECE99D048] PRIMARY KEY CLUSTERED  ([RELATIONID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2c_cdate_idx] ON [dbo].[USERCONTENT_RELATION] ([CREATIONDATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [r_u2c_creator_idx] ON [dbo].[USERCONTENT_RELATION] ([CREATOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [r_u2c_lastmodifier_idx] ON [dbo].[USERCONTENT_RELATION] ([LASTMODIFIER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2c_relationname_idx] ON [dbo].[USERCONTENT_RELATION] ([RELATIONNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2c_sourceuser_idx] ON [dbo].[USERCONTENT_RELATION] ([SOURCEUSER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2c_targetcontent_idx] ON [dbo].[USERCONTENT_RELATION] ([TARGETCONTENTID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [u2c_relation_unique] UNIQUE NONCLUSTERED  ([TARGETCONTENTID], [SOURCEUSER], [RELATIONNAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [relation_u2c_targettype_idx] ON [dbo].[USERCONTENT_RELATION] ([TARGETTYPE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [FK_RELATION_U2CUSER] FOREIGN KEY ([SOURCEUSER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [FK_U2CRELATION_CREATOR] FOREIGN KEY ([CREATOR]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [FK_U2CRELATION_LASTMODIFIER] FOREIGN KEY ([LASTMODIFIER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[USERCONTENT_RELATION] ADD CONSTRAINT [FKECD19CED351D64C3] FOREIGN KEY ([TARGETCONTENTID]) REFERENCES [dbo].[CONTENT] ([CONTENTID])
GO
