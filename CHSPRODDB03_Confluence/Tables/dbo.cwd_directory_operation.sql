CREATE TABLE [dbo].[cwd_directory_operation]
(
[directory_id] [numeric] (19, 0) NOT NULL,
[operation_type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_operation] ADD CONSTRAINT [PK__cwd_dire__2761B7877298CD86] PRIMARY KEY CLUSTERED  ([directory_id], [operation_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_directory_operation] ADD CONSTRAINT [fk_directory_operation] FOREIGN KEY ([directory_id]) REFERENCES [dbo].[cwd_directory] ([id])
GO
