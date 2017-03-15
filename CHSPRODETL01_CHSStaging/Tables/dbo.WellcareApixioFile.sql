CREATE TABLE [dbo].[WellcareApixioFile]
(
[WellcareApixioFileID] [int] NOT NULL IDENTITY(1, 1),
[Extract_Date] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_Member_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_Last_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_First_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_Provider_ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prov_Last_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prov_First_name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resolution] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Chart_File_Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Approx_Page_Count] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Project_Code] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceivedDate] [datetime] NULL CONSTRAINT [DF_WellcareApixioFile_Stage_ReceivedDate] DEFAULT (getdate()),
[Suspect_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WellcareApixioFile] ADD CONSTRAINT [PK_WellcareApixioFile_Stage] PRIMARY KEY CLUSTERED  ([WellcareApixioFileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartFileName] ON [dbo].[WellcareApixioFile] ([Chart_File_Name]) ON [PRIMARY]
GO
