CREATE TABLE [internal].[operation_permissions]
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
ALTER TABLE [internal].[operation_permissions] ADD CONSTRAINT [CK_Operation_PermissionType] CHECK (([permission_type]=(4) OR [permission_type]=(2) OR [permission_type]=(1)))
GO
ALTER TABLE [internal].[operation_permissions] ADD CONSTRAINT [PK_Operation_Permissions] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [Unique_OperationPermissions] ON [internal].[operation_permissions] ([object_id], [permission_type], [sid]) ON [PRIMARY]
GO
ALTER TABLE [internal].[operation_permissions] ADD CONSTRAINT [FK_OperationPermissions_ObjectId_Operations] FOREIGN KEY ([object_id]) REFERENCES [internal].[operations] ([operation_id]) ON DELETE CASCADE
GO
