CREATE TABLE [dbo].[managedconfigurationitem]
(
[ID] [numeric] (18, 0) NOT NULL,
[ITEM_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ITEM_TYPE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MANAGED] [nvarchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ACCESS_LEVEL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SOURCE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[managedconfigurationitem] ADD CONSTRAINT [PK_managedconfigurationitem] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [managedconfigitem_id_type_idx] ON [dbo].[managedconfigurationitem] ([ITEM_ID], [ITEM_TYPE]) ON [PRIMARY]
GO
