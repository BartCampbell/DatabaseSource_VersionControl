CREATE TABLE [dbo].[sharepermissions]
(
[ID] [numeric] (18, 0) NOT NULL,
[entityid] [numeric] (18, 0) NULL,
[entitytype] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[sharetype] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PARAM1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PARAM2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sharepermissions] ADD CONSTRAINT [PK_sharepermissions] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [share_index] ON [dbo].[sharepermissions] ([entityid], [entitytype]) ON [PRIMARY]
GO
