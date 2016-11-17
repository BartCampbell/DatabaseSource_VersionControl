CREATE TABLE [dbo].[L_ClaimLocation]
(
[L_ClaimLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Claim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Location_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimLocation] ADD CONSTRAINT [PK_L_ClaimLocation] PRIMARY KEY CLUSTERED  ([L_ClaimLocation_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimLocation] ADD CONSTRAINT [FK_L_ClaimLocation_H_Claim] FOREIGN KEY ([H_Claim_RK]) REFERENCES [dbo].[H_Claim] ([H_Claim_RK])
GO
ALTER TABLE [dbo].[L_ClaimLocation] ADD CONSTRAINT [FK_L_ClaimLocation_H_Location] FOREIGN KEY ([H_Location_RK]) REFERENCES [dbo].[H_Location] ([H_Location_RK])
GO
