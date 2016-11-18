CREATE TABLE [dim].[MemberClient]
(
[MemberClientID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ClientID] [int] NOT NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_MemberClient_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_MemberClient_RecordEndDate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberClient] ADD CONSTRAINT [PK_MemberClient] PRIMARY KEY CLUSTERED  ([MemberClientID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_MemberClient_17_628197288__K3_K2_K4] ON [dim].[MemberClient] ([ClientID], [MemberID], [ClientMemberID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_628197288_2_3_4] ON [dim].[MemberClient] ([MemberID], [ClientID], [ClientMemberID])
GO
ALTER TABLE [dim].[MemberClient] ADD CONSTRAINT [FK_MemberClient_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
ALTER TABLE [dim].[MemberClient] ADD CONSTRAINT [FK_MemberClient_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
