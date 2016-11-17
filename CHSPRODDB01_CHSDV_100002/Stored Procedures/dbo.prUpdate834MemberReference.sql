SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	04/25/2016
-- Description:	Loads new members into the member reference table from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prUpdate834MemberReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834MemberReference]
    @RecordSource VARCHAR(255)
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

             --LOAD NEW MEMBERS FROM 834 STAGING
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            c.CentauriClientID ,
                            ISNULL(i.MemberLevelDetail_RefID1_REF02, '') AS ClientMemberID ,
                            GETDATE() ,
                            @RecordSource
                    FROM    CHSStaging.dbo.X12_834_RawImport i
                            INNER JOIN ETLConfig.dbo.TradingPartnerFile AS t ON i.FileLevelDetail_SenderID_GS02 = t.SenderID
                                                                                 AND i.FileLevelDetail_ReceiverID_GS03 = t.ReceiverID
                            INNER JOIN CHSDV.dbo.R_Client AS c ON t.TradingPartner = c.ClientName
                            LEFT JOIN CHSDV.dbo.R_Member AS r ON i.MemberLevelDetail_RefID1_REF02 = r.ClientMemberID
                                                                 AND c.CentauriClientID = r.ClientID
                    WHERE   r.CentauriMemberID IS NULL
                            AND ISNULL(i.MemberLevelDetail_RefID1_REF02, '') <> '';


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
