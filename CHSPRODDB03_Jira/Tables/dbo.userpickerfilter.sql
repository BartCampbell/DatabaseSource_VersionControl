CREATE TABLE [dbo].[userpickerfilter]
(
[ID] [numeric] (18, 0) NOT NULL,
[CUSTOMFIELD] [numeric] (18, 0) NULL,
[CUSTOMFIELDCONFIG] [numeric] (18, 0) NULL,
[enabled] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userpickerfilter] ADD CONSTRAINT [PK_userpickerfilter] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [upf_customfield] ON [dbo].[userpickerfilter] ([CUSTOMFIELD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [upf_fieldconfigid] ON [dbo].[userpickerfilter] ([CUSTOMFIELDCONFIG]) ON [PRIMARY]
GO
