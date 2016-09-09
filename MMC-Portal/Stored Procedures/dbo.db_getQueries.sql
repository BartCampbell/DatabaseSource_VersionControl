SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Modify by Amjad ali on Feb-26-2015
-- db_getQueries 0,1
CREATE PROCEDURE [dbo].[db_getQueries] 
@h_id int,
@isClient int
AS
BEGIN
	if (@isClient=0)
	BEGIN
		SELECT TOP 12 COUNT(*) Queries,
			SUM(CASE WHEN IsNull(Q.IsCodedPosted,0)=0 THEN 1 ELSE 0 END) OpenQueries,
			MONTH(inserted_date) EncMonth,Year(inserted_date) EncYear
		FROM tblQuery Q WITH (NOLOCK) INNER JOIN tblEncounter E WITH (NOLOCK) ON E.encounter_pk = Q.Encounter_PK
		WHERE E.h_id=@h_id AND   inserted_date IS NOT NULL AND ISNULL([query_text],'')<>''
		GROUP BY MONTH(inserted_date),Year(inserted_date)
		ORDER BY EncYear DESC,EncMonth DESC
	END
	else
	BEGIN
	SELECT TOP 3 COUNT(*) Queries,
			SUM(CASE WHEN IsNull(Q.IsCodedPosted,0)=0 THEN 1 ELSE 0 END) OpenQueries,
			MONTH(inserted_date) EncMonth,Year(inserted_date) EncYear
		FROM tblQuery Q WITH (NOLOCK) INNER JOIN tblEncounter E WITH (NOLOCK) ON E.encounter_pk = Q.Encounter_PK
		WHERE E.h_id=@h_id AND   inserted_date IS NOT NULL AND ISNULL([query_text],'')<>''
		GROUP BY MONTH(inserted_date),Year(inserted_date)
		ORDER BY EncYear DESC,EncMonth DESC
	END
END


GO
