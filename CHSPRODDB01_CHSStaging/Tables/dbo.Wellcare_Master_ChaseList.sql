CREATE TABLE [dbo].[Wellcare_Master_ChaseList]
(
[Chart ID] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsCentauri] [bit] NULL CONSTRAINT [DF_Wellcare_Master_ChaseList_IsCentauri] DEFAULT ((0)),
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
[RecID] [int] NOT NULL IDENTITY(1, 1),
[Channel] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Wellcare_Master_ChaseList] ADD CONSTRAINT [PK_Wellcare_Master_ChaseList] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Wellcare_Master_ChaseList_20_967114636__K1_K2_6] ON [dbo].[Wellcare_Master_ChaseList] ([Chart ID], [IsCentauri]) INCLUDE ([Member ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Wellcare_Master_ChaseList_20_967114636__K1_K2_13] ON [dbo].[Wellcare_Master_ChaseList] ([Chart ID], [IsCentauri]) INCLUDE ([Prov ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Wellcare_Master_ChaseList_20_967114636__K2_K1_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23_24_25_26_27_] ON [dbo].[Wellcare_Master_ChaseList] ([IsCentauri], [Chart ID]) INCLUDE ([ADDRESS], [Altegra LID], [Altegra Project], [Channel], [CHART STATUS], [CITY], [Column 15], [COMMENT], [Contract Number], [DOB], [FAX], [First Name], [For updates only ], [Gendor], [GROUP], [HICN], [Last Name], [LOB], [Member ID], [PHONE], [PROJECT], [PROV FIRST], [Prov ID], [PROV LAST], [RecID], [STATE], [ZIP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160831-133843] ON [dbo].[Wellcare_Master_ChaseList] ([Prov ID]) ON [PRIMARY]
GO
