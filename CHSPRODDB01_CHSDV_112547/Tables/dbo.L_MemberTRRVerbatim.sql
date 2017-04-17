CREATE TABLE [dbo].[L_MemberTRRVerbatim]
(
[L_MemberTRRVerbatim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_TRRVerbatim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberTRRVerbatim] ADD CONSTRAINT [PK_L_MemberTRRVerbatim] PRIMARY KEY CLUSTERED  ([L_MemberTRRVerbatim_RK]) ON [PRIMARY]
GO
