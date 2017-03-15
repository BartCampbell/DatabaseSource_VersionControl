SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/4/2015
-- Description:	Add and update member information to obtain correct Member ID
-- =============================================
CREATE PROCEDURE [dbo].[prMergeMembers]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	;WITH mysource as (
    Select ClientMemberID, MemberHashKey, SSN, CCI
	from CHSStaging..Member_Stage_Raw
	group by ClientMemberID, MemberHashKey, SSN, CCI
	)

MERGE CHSStaging..Member_Stage AS t
USING mySource s
     ON s.MemberHashKey = t.MemberHashKey
WHEN NOT MATCHED THEN INSERT
    (
       ClientMemberID, MemberHashKey, SSN, CCI
    )
    VALUES (
        rtrim(ltrim(s.ClientMemberID)), 
        rtrim(ltrim(s.MemberHashKey)),
		rtrim(ltrim(s.SSN)), 
        rtrim(ltrim(s.CCI))
      )
	  
WHEN MATCHED 
    THEN UPDATE SET t.ClientMemberID = s.ClientMemberID
	,t.MemberHashKey=s.MemberHashKey
	,t.SSN=s.SSN
	,t.CCI=s.CCI
	
WHEN NOT MATCHED BY SOURCE 
 then update set t.IsActive = 0
	;

END
GO
