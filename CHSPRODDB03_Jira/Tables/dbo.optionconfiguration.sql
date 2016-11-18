CREATE TABLE [dbo].[optionconfiguration]
(
[ID] [numeric] (18, 0) NOT NULL,
[FIELDID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OPTIONID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FIELDCONFIG] [numeric] (18, 0) NULL,
[SEQUENCE] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[optionconfiguration] ADD CONSTRAINT [PK_optionconfiguration] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldid_fieldconf] ON [dbo].[optionconfiguration] ([FIELDID], [FIELDCONFIG]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fieldid_optionid] ON [dbo].[optionconfiguration] ([FIELDID], [OPTIONID]) ON [PRIMARY]
GO
