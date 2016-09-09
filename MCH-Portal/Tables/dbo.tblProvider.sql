CREATE TABLE [dbo].[tblProvider]
(
[provider_pk] [smallint] NOT NULL IDENTITY(1, 1),
[department_pk] [smallint] NULL,
[provider_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[istemp] [bit] NULL CONSTRAINT [DF_tblProvider_istemp] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProvider] ADD CONSTRAINT [PK_tblProvider] PRIMARY KEY CLUSTERED  ([provider_pk]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProvider_Department] ON [dbo].[tblProvider] ([department_pk]) ON [PRIMARY]
GO
