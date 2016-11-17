SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	07/20/2016
-- Description:	Adds new columns to the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prUpdate834StagingColumns 
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834StagingColumns]
AS
    BEGIN
	   
        DECLARE @CurrentDate DATETIME = GETDATE();

        SET NOCOUNT ON;


        BEGIN TRY

            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'CentauriClientID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD CentauriClientID BIGINT;

            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Client_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Client_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'RecordSource' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD RecordSource VARCHAR(255);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'LoadDate' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD LoadDate DATETIME;
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'CentauriProviderID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD CentauriProviderID BIGINT;
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Provider_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Provider_RK CHAR(32); 
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_ProviderDemo_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_ProviderDemo_HashDiff CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_ProviderDemo_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_ProviderDemo_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'ProviderID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD ProviderID VARCHAR(50);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'NetworkID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD NetworkID VARCHAR(50);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Network_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Network_RK VARCHAR(50);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'CentauriNetworkID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD CentauriNetworkID BIGINT;
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'CentauriMemberID' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD CentauriMemberID BIGINT;
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Member_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Member_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'L_MemberProvider_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD L_MemberProvider_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Location_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Location_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'Location_BK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD Location_BK VARCHAR(255);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'L_MemberLocation_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD L_MemberLocation_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberHICN_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberHICN_HashDiff CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberHICN_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberHICN_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberElig_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberElig_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberElig_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberElig_HashDiff CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberDemo_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberDemo_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_MemberDemo_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_MemberDemo_HashDiff CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'H_Contact_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD H_Contact_RK CHAR(32);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'Contact_BK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD Contact_BK CHAR(255);
            
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'L_MemberContact_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD L_MemberContact_RK CHAR(32);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_Contact_834_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_Contact_834_RK CHAR(32);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_Contact_834_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_Contact_834_HashDiff CHAR(32);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_Location_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_Location_RK CHAR(32);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'S_Location_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD S_Location_HashDiff CHAR(32);
		  
		  IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'LS_MemberProvider_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD LS_MemberProvider_RK CHAR(32);
		  
            IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'LS_MemberProvider_HashDiff' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD LS_MemberProvider_HashDiff CHAR(32);
		  
		  IF NOT EXISTS ( SELECT  *
                            FROM    CHSStaging.sys.columns c
                                    INNER JOIN CHSStaging.sys.tables t ON t.object_id = c.object_id
                                    INNER JOIN CHSStaging.sys.schemas s ON s.schema_id = t.schema_id
                            WHERE   s.name = 'dbo'
                                    AND t.name = 'X12_834_RawImport'
                                    AND c.name = 'L_ProviderNetwork_RK' )
                ALTER TABLE CHSStaging.dbo.X12_834_RawImport ADD L_ProviderNetwork_RK CHAR(32);


        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;
GO
