SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Modify by Amjad Ali Awan
-- added new @h_id
-- db_getCoderProgress 0
CREATE PROCEDURE [dbo].[db_getCoderProgress] 
@h_id smallint
AS
BEGIN
	DECLARE @Month AS INT = MONTH(GETDATE())
	if (SELECT COUNT(*)	FROM tblEncounter WITH (NOLOCK) WHERE h_id=@h_id AND MONTH(inserted_date)=@Month AND Year(inserted_date)=Year(GETDATE()))=0 
		SET @Month = MONTH(GETDATE())-1
		
	DECLARE @WeekNum AS INT
	SET @WeekNum = DatePart(Week,CAST(@Month AS VARCHAR)+'-1-'+CAST(YEAR(GETDATE()) AS VARCHAR))-1

	SELECT DISTINCT TOP 12 DatePart(Week,inserted_date)-@WeekNum WeekNum,MAX(inserted_date) Weekend
	FROM tblEncounter WITH (NOLOCK)
	WHERE h_id=@h_id AND MONTH(inserted_date)=@Month AND Year(inserted_date)=Year(GETDATE())
	GROUP BY DatePart(Week,inserted_date)
 
	SELECT DISTINCT max(User_PK) User_PK,Lastname+', '+Firstname Coder,
	SUM(CASE WHEN MONTH(inserted_date) = MONTH(dateadd(MM,-2,getdate())) THEN 1 ELSE 0 END) as [Month1],
	SUM(CASE WHEN MONTH(inserted_date) = MONTH(dateadd(MM,-1,getdate())) THEN 1 ELSE 0 END) as [Month2],
	SUM(CASE WHEN MONTH(inserted_date) = MONTH(dateadd(MM,0,getdate())) THEN 1 ELSE 0 END) as [Month3]
	FROM tblEncounter E WITH (NOLOCK) INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = E.inserted_user_pk
	WHERE  E.h_id=@h_id AND inserted_date>getdate() -95
	GROUP BY Email_Address,Lastname+', '+Firstname
	ORDER BY Lastname+', '+Firstname,User_PK
	
	SELECT COUNT(*) Encounters,DatePart(Week,inserted_date)-@WeekNum WeekNum,inserted_user_pk User_PK
	FROM tblEncounter E WITH (NOLOCK) INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = E.inserted_user_pk
	WHERE E.h_id=@h_id AND MONTH(inserted_date)=@Month AND Year(inserted_date)=Year(GETDATE())
	GROUP BY DatePart(Week,inserted_date)-@WeekNum,inserted_user_pk
	ORDER BY inserted_user_pk,WeekNum
END


GO
