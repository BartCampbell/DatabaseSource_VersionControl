CREATE TABLE [fact].[MemberPCP]
(
[MemberPCPID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[PCPEffectiveDate] [date] NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberPCP] ADD CONSTRAINT [PK_MemberPCP] PRIMARY KEY CLUSTERED  ([MemberPCPID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberPCP] ADD CONSTRAINT [FK_MemberPCP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[MemberPCP] ADD CONSTRAINT [FK_MemberPCP_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
