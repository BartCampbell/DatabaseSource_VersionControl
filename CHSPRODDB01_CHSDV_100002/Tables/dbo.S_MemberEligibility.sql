CREATE TABLE [dbo].[S_MemberEligibility]
(
[S_MemberElig_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveStartDate] [datetime] NULL,
[EffectiveEndDate] [datetime] NULL,
[GroupEffectiveDate] [datetime] NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberEligibility] ADD CONSTRAINT [PK_S_MemberEligibility] PRIMARY KEY CLUSTERED  ([S_MemberElig_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberEligibility] ADD CONSTRAINT [FK_S_MemberEffective_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
