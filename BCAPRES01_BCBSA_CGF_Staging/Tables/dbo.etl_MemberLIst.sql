CREATE TABLE [dbo].[etl_MemberLIst]
(
[etl_MemberLIstID] [int] NOT NULL IDENTITY(1, 1),
[LoadGuid] [uniqueidentifier] NULL,
[ihds_member_id] [int] NULL
) ON [PRIMARY]
GO
