CREATE TABLE [dbo].[portletconfiguration]
(
[ID] [numeric] (18, 0) NOT NULL,
[PORTALPAGE] [numeric] (18, 0) NULL,
[PORTLET_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[COLUMN_NUMBER] [int] NULL,
[positionseq] [int] NULL,
[GADGET_XML] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[COLOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DASHBOARD_MODULE_COMPLETE_KEY] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[portletconfiguration] ADD CONSTRAINT [PK_portletconfiguration] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
