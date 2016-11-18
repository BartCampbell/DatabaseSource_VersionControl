CREATE TABLE [dbo].[PAGETEMPLATES]
(
[TEMPLATEID] [numeric] (19, 0) NOT NULL,
[HIBERNATEVERSION] [int] NOT NULL CONSTRAINT [DF__PAGETEMPL__HIBER__7814D14C] DEFAULT ((0)),
[TEMPLATENAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[TEMPLATEDESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PLUGINKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MODULEKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[REFPLUGINKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[REFMODULEKEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CONTENT] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SPACEID] [numeric] (19, 0) NULL,
[PREVVER] [numeric] (19, 0) NULL,
[VERSION] [int] NOT NULL,
[CREATOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CREATIONDATE] [datetime] NULL,
[LASTMODIFIER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LASTMODDATE] [datetime] NULL,
[BODYTYPEID] [smallint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAGETEMPLATES] ADD CONSTRAINT [PK__PAGETEMP__9EE4AD53A00563E3] PRIMARY KEY CLUSTERED  ([TEMPLATEID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pt_creator_idx] ON [dbo].[PAGETEMPLATES] ([CREATOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pt_lastmodifier_idx] ON [dbo].[PAGETEMPLATES] ([LASTMODIFIER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pt_prevver_idx] ON [dbo].[PAGETEMPLATES] ([PREVVER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pt_spaceid_idx] ON [dbo].[PAGETEMPLATES] ([SPACEID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAGETEMPLATES] ADD CONSTRAINT [FK_PAGETEMPLATES_CREATOR] FOREIGN KEY ([CREATOR]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[PAGETEMPLATES] ADD CONSTRAINT [FK_PAGETEMPLATES_LASTMODIFIER] FOREIGN KEY ([LASTMODIFIER]) REFERENCES [dbo].[user_mapping] ([user_key])
GO
ALTER TABLE [dbo].[PAGETEMPLATES] ADD CONSTRAINT [FKBC7CE96A17D4A070] FOREIGN KEY ([PREVVER]) REFERENCES [dbo].[PAGETEMPLATES] ([TEMPLATEID])
GO
ALTER TABLE [dbo].[PAGETEMPLATES] ADD CONSTRAINT [FKBC7CE96AB2DC6081] FOREIGN KEY ([SPACEID]) REFERENCES [dbo].[SPACES] ([SPACEID])
GO
