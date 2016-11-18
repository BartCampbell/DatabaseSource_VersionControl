CREATE TABLE [dbo].[userhistoryitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[entitytype] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[entityid] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[USERNAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[lastviewed] [numeric] (18, 0) NULL,
[data] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[userhistoryitem] ADD CONSTRAINT [PK_userhistoryitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uh_type_user_entity] ON [dbo].[userhistoryitem] ([entitytype], [USERNAME], [entityid]) ON [PRIMARY]
GO
