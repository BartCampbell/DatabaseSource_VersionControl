CREATE TABLE [dbo].[ProviderGroup]
(
[ProviderGroupID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderGroup] ADD CONSTRAINT [PK_ProviderGroup] PRIMARY KEY CLUSTERED  ([ProviderGroupID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderGroup] ADD CONSTRAINT [FK_ProviderGroup_Group] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Group] ([GroupID])
GO
ALTER TABLE [dbo].[ProviderGroup] ADD CONSTRAINT [FK_ProviderGroup_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
