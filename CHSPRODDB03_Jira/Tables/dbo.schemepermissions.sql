CREATE TABLE [dbo].[schemepermissions]
(
[ID] [numeric] (18, 0) NOT NULL,
[SCHEME] [numeric] (18, 0) NULL,
[PERMISSION] [numeric] (18, 0) NULL,
[perm_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[perm_parameter] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PERMISSION_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schemepermissions] ADD CONSTRAINT [PK_schemepermissions] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [permission_key_idx] ON [dbo].[schemepermissions] ([PERMISSION_KEY]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [prmssn_scheme] ON [dbo].[schemepermissions] ([SCHEME]) ON [PRIMARY]
GO
