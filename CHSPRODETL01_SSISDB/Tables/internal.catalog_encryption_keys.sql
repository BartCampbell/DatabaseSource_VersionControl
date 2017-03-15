CREATE TABLE [internal].[catalog_encryption_keys]
(
[key_id] [bigint] NOT NULL IDENTITY(1, 1),
[key_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KEY] [varbinary] (8000) NOT NULL,
[IV] [varbinary] (8000) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[catalog_encryption_keys] ADD CONSTRAINT [PK_Encryption_Keys] PRIMARY KEY CLUSTERED  ([key_id]) ON [PRIMARY]
GO
