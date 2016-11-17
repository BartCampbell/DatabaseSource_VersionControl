SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:		Travis Parker
-- Create date:	08/30/2016
-- Description:	Loads all the Links from the OEC staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OECStratum_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OECStratum_LoadLinks]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


		  --LOAD L_MemberOECProject
            INSERT  INTO dbo.L_MemberOECProject
                    ( L_MemberOECProject_RK ,
                      H_Member_RK ,
                      H_OECProject_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  DISTINCT
                            L_MemberOECProject_RK ,
                            H_Member_RK ,
                            H_OECProject_RK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.EnrolleeStratum_112548
                    WHERE   L_MemberOECProject_RK NOT IN ( SELECT   L_MemberOECProject_RK
                                                           FROM     dbo.L_MemberOECProject );



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
