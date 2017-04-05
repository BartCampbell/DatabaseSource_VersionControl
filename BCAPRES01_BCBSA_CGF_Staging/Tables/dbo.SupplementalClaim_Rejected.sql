CREATE TABLE [dbo].[SupplementalClaim_Rejected]
(
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SrcTabDB] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SrcTabSchema] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SrcTabName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [int] NULL,
[RowFileID] [int] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[RejecteReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
