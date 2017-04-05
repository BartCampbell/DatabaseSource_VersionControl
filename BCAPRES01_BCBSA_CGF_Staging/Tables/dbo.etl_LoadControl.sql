CREATE TABLE [dbo].[etl_LoadControl]
(
[LoadInstanceID] [int] NULL,
[LoadGuid] [uniqueidentifier] NULL,
[LoadStartDate] [datetime] NULL,
[LoadEndDate] [datetime] NULL,
[MemberIncrFlag] [bit] NULL,
[ProvIncrFlag] [bit] NULL,
[MedClaimIncrFlag] [bit] NULL,
[RXClaimIncrFlag] [bit] NULL
) ON [PRIMARY]
GO
