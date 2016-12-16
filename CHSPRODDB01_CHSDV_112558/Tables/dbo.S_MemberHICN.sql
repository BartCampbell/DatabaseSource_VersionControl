CREATE TABLE [dbo].[S_MemberHICN]
(
[S_MemberHICN_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberHICN] ADD CONSTRAINT [PK_S_MemberHICN] PRIMARY KEY CLUSTERED  ([S_MemberHICN_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-080959] ON [dbo].[S_MemberHICN] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberHICN] ADD CONSTRAINT [FK_S_MemberHICN_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
