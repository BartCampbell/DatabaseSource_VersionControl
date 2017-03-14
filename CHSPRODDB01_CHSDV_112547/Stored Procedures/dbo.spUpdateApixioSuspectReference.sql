SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	12/14/2016
-- Description:	Updates the suspect_pk from looking at the DV using the chaseid
-- Usage:			
--		  EXECUTE dbo.spUpdateApixioSuspectReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateApixioSuspectReference]
AS
     BEGIN

         SET NOCOUNT ON;
	    
         BEGIN TRY

             BEGIN TRANSACTION;

			 --update the chases with CENT on them
			 UPDATE  a
			 SET     Suspect_PK = t.Suspect_PK
			 FROM    CHSStaging.dbo.ApixioReturn a
				    INNER JOIN dbo.vwSuspectMember t ON a.CHART_ID + 'CENT' = t.ChaseID AND t.ClientMemberID = a.MEMBER_ID
			 WHERE a.Suspect_PK IS NULL; 

			 --update remaining chases without the CENT
			 UPDATE  a
			 SET     Suspect_PK = t.Suspect_PK
			 FROM    CHSStaging.dbo.ApixioReturn a
				    INNER JOIN dbo.vwSuspectMember t ON a.CHART_ID = t.ChaseID AND t.ClientMemberID = a.MEMBER_ID
			 WHERE   a.Suspect_PK IS NULL; 

             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;

GO
