CREATE TABLE [dbo].[cwd_user_credential_record]
(
[id] [numeric] (19, 0) NOT NULL,
[user_id] [numeric] (19, 0) NULL,
[password_hash] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[list_index] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_credential_record] ADD CONSTRAINT [PK__cwd_user__3213E83F8D00BD91] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_user_cred_record_user_id] ON [dbo].[cwd_user_credential_record] ([user_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cwd_user_credential_record] ADD CONSTRAINT [FK76F874F73AEE0F] FOREIGN KEY ([user_id]) REFERENCES [dbo].[cwd_user] ([id])
GO
