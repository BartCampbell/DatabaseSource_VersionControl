CREATE TABLE [dbo].[S_OEC_DNC]
(
[S_OEC_DNC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_OEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Issuer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OEC_DNC] ADD CONSTRAINT [PK_S_OEC_DNC] PRIMARY KEY CLUSTERED  ([S_OEC_DNC_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_OEC_DNC] ADD CONSTRAINT [FK_S_OEC_DNC_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
