CREATE TABLE [dbo].[MemberProvider]
(
[MemberProviderID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [PK_MemberProvider] PRIMARY KEY CLUSTERED  ([MemberProviderID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [FK_MemberProvider_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [FK_MemberProvider_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
