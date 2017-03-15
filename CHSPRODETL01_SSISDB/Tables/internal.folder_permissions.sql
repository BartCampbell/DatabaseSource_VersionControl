CREATE TABLE [internal].[folder_permissions]
(
[id] [bigint] NOT NULL IDENTITY(1, 1),
[sid] [internal].[adt_sid] NOT NULL,
[object_id] [bigint] NOT NULL,
[permission_type] [smallint] NOT NULL,
[is_role] [bit] NOT NULL,
[is_deny] [bit] NOT NULL,
[grantor_sid] [internal].[adt_sid] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[folder_permissions] ADD CONSTRAINT [CK_Folder_PermissionType] CHECK (([permission_type]=(104) OR [permission_type]=(103) OR [permission_type]=(102) OR [permission_type]=(101) OR [permission_type]=(100) OR [permission_type]=(4) OR [permission_type]=(2) OR [permission_type]=(1)))
GO
ALTER TABLE [internal].[folder_permissions] ADD CONSTRAINT [PK_Folder_Permissions] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Unique_FolderPermissions] ON [internal].[folder_permissions] ([object_id], [permission_type], [sid]) ON [PRIMARY]
GO
ALTER TABLE [internal].[folder_permissions] ADD CONSTRAINT [FK_FolderPermissions_ObjectId_Folders] FOREIGN KEY ([object_id]) REFERENCES [internal].[folders] ([folder_id]) ON DELETE CASCADE
GO
