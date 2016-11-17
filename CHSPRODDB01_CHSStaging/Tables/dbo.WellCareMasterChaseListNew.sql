CREATE TABLE [dbo].[WellCareMasterChaseListNew]
(
[MasterChaseListID] [int] NOT NULL IDENTITY(1, 1),
[Chart ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Contract Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Altegra LID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Altegra Project] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prov ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROV LAST] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROV FIRST] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS 2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHONE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GROUP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROJECT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART STATUS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[For updates only] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Crosswalk] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Altegra] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Centauri] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIOX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LORI UPDATES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_INFO_UPDATE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_Member_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_HICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_First_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_Last_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_PROVIDER_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_SEQ_PROV_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SYS_NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCentauri] [bit] NULL,
[CentauriProviderID] [bigint] NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WellCareMasterChaseListNew] ADD CONSTRAINT [PK_WellCareMasterChaseListNew] PRIMARY KEY CLUSTERED  ([MasterChaseListID]) ON [PRIMARY]
GO
