CREATE TABLE [dbo].[WellCareNonCHSMasterChaseList]
(
[Chart ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCentauri] [bit] NULL,
[Contract Number] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Altegra LID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Altegra Project] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gendor] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOB] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prov ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROV LAST] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROV FIRST] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column 15] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GROUP] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROJECT] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART STATUS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENT] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[For updates only ] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecID] [int] NOT NULL,
[Channel] [int] NULL,
[CentauriProviderID] [bigint] NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WellCareNonCHSMasterChaseList] ADD CONSTRAINT [PK_WellCareNonCHSMasterChaseList] PRIMARY KEY CLUSTERED  ([Chart ID]) ON [PRIMARY]
GO
