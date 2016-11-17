CREATE TABLE [dbo].[R_Member]
(
[CentauriMemberID] [int] NOT NULL IDENTITY(1000023682, 1),
[SSN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriMemberID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Member] ADD CONSTRAINT [PK_R_Member] PRIMARY KEY CLUSTERED  ([CentauriMemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_R_Member_7_190623722__K3_K4_K1] ON [dbo].[R_Member] ([ClientID], [ClientMemberID], [CentauriMemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ClientMemberID_ClientID] ON [dbo].[R_Member] ([ClientMemberID], [ClientID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1665441007_5_1] ON [dbo].[R_Member] ([ClientMemberID], [CentauriMemberID])
GO
