CREATE TABLE [dbo].[Viva_Member_File]
(
[Member ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Effective Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expiration Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberName] ON [dbo].[Viva_Member_File] ([Member Name]) ON [PRIMARY]
GO
