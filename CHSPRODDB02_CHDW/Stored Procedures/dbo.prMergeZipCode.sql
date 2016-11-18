SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prMergeZipCode]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	SET NOCOUNT ON;


SET IDENTITY_INSERT [ref].[Zipcode] ON;
    
MERGE [ref].[Zipcode] AS t
USING (SELECT * FROM [CHSStaging].[dbo].[Zipcode] WITH(NOLOCK)) as s
ON (  t.[ZipCode] = s.[ZipCode] )
WHEN MATCHED THEN UPDATE SET
    [City] = s.[City],
    [State] = s.[State]
 WHEN NOT MATCHED BY TARGET THEN
    INSERT([ZipCodeID], [ZipCode], [City], [State])
    VALUES(s.[ZipCodeID], s.[ZipCode], s.[City], s.[State])
WHEN NOT MATCHED BY SOURCE THEN DELETE; 

SET IDENTITY_INSERT [ref].[Zipcode] OFF;
 
END
GO
