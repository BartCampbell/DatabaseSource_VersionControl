CREATE TABLE [dbo].[H_GNClaimRpt]
(
[H_GNClaimRpt_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GNClaimRpt_BK] [int] NULL,
[ClientGNClaimRptID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_GNClaimRpt_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_GNClaimRpt] ADD CONSTRAINT [PK_H_GNClaimRpt] PRIMARY KEY CLUSTERED  ([H_GNClaimRpt_RK]) ON [PRIMARY]
GO
