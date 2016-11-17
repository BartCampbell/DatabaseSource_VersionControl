CREATE TABLE [mor].[MOR_Trailer_Stage]
(
[RecordTypeCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalRecordCount] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_MOR_Trailer_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_MOR_Header_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
