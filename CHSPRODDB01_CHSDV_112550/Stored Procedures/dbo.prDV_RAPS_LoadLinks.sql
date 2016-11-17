SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/10/2016
-- Description:	Loads all the Links from the RAPS staging tables
-- Usage:			
--		  EXECUTE dbo.prDV_RAPS_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[prDV_RAPS_LoadLinks]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


		  --LOAD MemberOEC Link
            INSERT  INTO dbo.L_MemberRAPSResponse
                    ( L_MemberRAPSResponse_RK ,
                      H_RAPS_Response_RK ,
                      H_Member_RK ,
                      LoadDate ,
                      RecordSource 
                    )
                    SELECT DISTINCT
                            L_MemberRAPSResponse_RK ,
                            H_RAPS_Response_RK ,
					   H_Member_RK ,
					   LoadDate ,
					   RecordSource 
                    FROM    CHSStaging.raps.RAPS_RESPONSE_CCC
                    WHERE   L_MemberRAPSResponse_RK NOT IN ( SELECT  L_MemberRAPSResponse_RK
                                                    FROM    dbo.L_MemberRAPSResponse );


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;

GO
