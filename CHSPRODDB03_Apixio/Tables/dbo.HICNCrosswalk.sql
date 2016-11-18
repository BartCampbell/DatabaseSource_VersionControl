CREATE TABLE [dbo].[HICNCrosswalk]
(
[Pat_ID] [varchar] (30) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[HICN] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[From_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Thru_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Date_Refreshed] [datetime] NOT NULL,
[Date_Retreived] [datetime] NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HICNCrosswalk] ADD CONSTRAINT [PK_HICNCrosswalk_RecID] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
