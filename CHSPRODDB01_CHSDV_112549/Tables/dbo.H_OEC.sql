CREATE TABLE [dbo].[H_OEC]
(
[H_OEC_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OEC_BK] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_OEC] ADD CONSTRAINT [PK_H_OEC] PRIMARY KEY CLUSTERED  ([H_OEC_RK]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'ClientID + ProviderID + MemberID + DOSFrom + DOSTo', 'SCHEMA', N'dbo', 'TABLE', N'H_OEC', 'COLUMN', N'OEC_BK'
GO
