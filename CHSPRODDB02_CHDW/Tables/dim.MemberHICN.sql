CREATE TABLE [dim].[MemberHICN]
(
[MemberHICNID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[HICN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordStartDate] [datetime] NOT NULL CONSTRAINT [DF_MemberHICN_CreateDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NOT NULL CONSTRAINT [DF_MemberHICN_LastUpdate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MemberHICN] ADD CONSTRAINT [PK_MemberHICN] PRIMARY KEY CLUSTERED  ([MemberHICNID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberHICN_10_539148966__K2_K3] ON [dim].[MemberHICN] ([MemberID], [HICN]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_539148966_1_2_3] ON [dim].[MemberHICN] ([MemberHICNID], [MemberID], [HICN])
GO
ALTER TABLE [dim].[MemberHICN] ADD CONSTRAINT [FK_MemberHICN_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
