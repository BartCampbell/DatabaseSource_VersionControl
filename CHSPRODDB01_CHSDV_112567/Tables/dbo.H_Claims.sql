CREATE TABLE [dbo].[H_Claims]
(
[H_Claims_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Claims_BK] [int] NULL,
[ClientClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_Claims_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_Claims] ADD CONSTRAINT [PK_H_Claims] PRIMARY KEY CLUSTERED  ([H_Claims_RK]) ON [PRIMARY]
GO
