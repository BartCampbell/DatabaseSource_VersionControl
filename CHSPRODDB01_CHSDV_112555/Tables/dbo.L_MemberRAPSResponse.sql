CREATE TABLE [dbo].[L_MemberRAPSResponse]
(
[L_MemberRAPSResponse_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_RAPS_Response_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_L_MemberRAPSResponse_LoadDate] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberRAPSResponse] ADD CONSTRAINT [PK_L_MemberRAPSResponse] PRIMARY KEY CLUSTERED  ([L_MemberRAPSResponse_RK]) ON [PRIMARY]
GO
