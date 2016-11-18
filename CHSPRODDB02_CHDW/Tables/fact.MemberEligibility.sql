CREATE TABLE [fact].[MemberEligibility]
(
[MemberEligibilityID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[GroupEffectiveDate] [int] NULL,
[Payor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [int] NOT NULL,
[EffectiveEndDate] [int] NOT NULL,
[CreateDate] [datetime] NULL,
[LastUpdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberEligibility] ADD CONSTRAINT [PK_MemberEligibility] PRIMARY KEY CLUSTERED  ([MemberEligibilityID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[MemberEligibility] ADD CONSTRAINT [FK_MemberEligibility_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
