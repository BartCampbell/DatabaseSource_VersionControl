CREATE TABLE [dbo].[MemberExtension]
(
[MemberID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberExtension] ADD CONSTRAINT [actMemberExtension_PK] PRIMARY KEY CLUSTERED  ([MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberExtension] ADD CONSTRAINT [actMember_MemberExtension_FK1] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[Member] ([MemberID])
GO
