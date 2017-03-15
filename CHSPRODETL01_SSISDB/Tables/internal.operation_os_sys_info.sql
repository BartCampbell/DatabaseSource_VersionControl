CREATE TABLE [internal].[operation_os_sys_info]
(
[info_id] [bigint] NOT NULL IDENTITY(1, 1),
[operation_id] [bigint] NOT NULL,
[total_physical_memory_kb] [bigint] NOT NULL,
[available_physical_memory_kb] [bigint] NULL,
[total_page_file_kb] [bigint] NULL,
[available_page_file_kb] [bigint] NOT NULL,
[cpu_count] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [internal].[operation_os_sys_info] ADD CONSTRAINT [PK_Operation_Os_Sys_Info] PRIMARY KEY CLUSTERED  ([info_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OsSysInfo_Operation_id] ON [internal].[operation_os_sys_info] ([operation_id]) ON [PRIMARY]
GO
ALTER TABLE [internal].[operation_os_sys_info] ADD CONSTRAINT [FK_OssysInfo_Operations] FOREIGN KEY ([operation_id]) REFERENCES [internal].[operations] ([operation_id]) ON DELETE CASCADE
GO
GRANT INSERT ON  [internal].[operation_os_sys_info] TO [ModuleSigner]
GO
