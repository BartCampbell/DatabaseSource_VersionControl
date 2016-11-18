CREATE TABLE [fact].[OECMemberHCC]
(
[OECMemberHCCID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[OECProjectID] [int] NOT NULL,
[HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[OECMemberHCC] ADD CONSTRAINT [PK_OECMemberHCC] PRIMARY KEY CLUSTERED  ([OECMemberHCCID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[OECMemberHCC] ADD CONSTRAINT [FK_OECMemberHCC_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[OECMemberHCC] ADD CONSTRAINT [FK_OECMemberHCC_OECProject] FOREIGN KEY ([OECProjectID]) REFERENCES [dim].[OECProject] ([OECProjectID])
GO
