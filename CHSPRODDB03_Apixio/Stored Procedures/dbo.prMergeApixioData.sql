SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prMergeApixioData]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

SET IDENTITY_INSERT [dbo].[ScannedDocumentMetadata] ON;
    
MERGE [dbo].[ScannedDocumentMetadata] AS t
USING (SELECT * FROM [Apixio].[dbo].[ScannedDocumentMetadata_Stage] WITH(NOLOCK)) as s
ON ( t.[RecID] = s.[RecID] )
WHEN MATCHED THEN UPDATE SET
    [Chase_ID] = s.[Chase_ID],
    [Date_Refreshed] = s.[Date_Refreshed],
    [Date_Retreived] = s.[Date_Retreived],
    [Document_ID] = s.[Document_ID],
    [Document_Title] = s.[Document_Title],
    [Document_Type] = s.[Document_Type],
    [File_Path_Name] = s.[File_Path_Name],
    [From_Date] = s.[From_Date],
    [Pat_ID] = s.[Pat_ID],
    [Provider_ID] = s.[Provider_ID],
    [Thru_Date] = s.[Thru_Date]
 WHEN NOT MATCHED BY TARGET THEN
    INSERT([Chase_ID], [Date_Refreshed], [Date_Retreived], [Document_ID], [Document_Title], [Document_Type], [File_Path_Name], [From_Date], [Pat_ID], [Provider_ID], [RecID], [Thru_Date])
    VALUES(s.[Chase_ID], s.[Date_Refreshed], s.[Date_Retreived], s.[Document_ID], s.[Document_Title], s.[Document_Type], s.[File_Path_Name], s.[From_Date], s.[Pat_ID], s.[Provider_ID], s.[RecID], s.[Thru_Date]);

	SET IDENTITY_INSERT [dbo].[ScannedDocumentMetadata] OFF;


END
GO
