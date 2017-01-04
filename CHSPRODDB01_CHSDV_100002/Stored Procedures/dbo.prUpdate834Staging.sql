SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	07/18/2016
-- Description:	Adds and updates the RKs in the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prUpdate834Staging 
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834Staging]
    @RecordSource VARCHAR(255)
AS
    BEGIN
	   
	   DECLARE @CurrentDate DATETIME = GETDATE()

        SET NOCOUNT ON;


        BEGIN TRY


            UPDATE  i
            SET     CentauriClientID = c.CentauriClientID ,
                    H_Client_RK = c.ClientHashKey ,
                    RecordSource = @RecordSource ,
				LoadDate = @CurrentDate ,
                    CentauriProviderID = p.CentauriProviderID ,
                    H_Provider_RK = p.ProviderHashKey ,
                    S_ProviderDemo_HashDiff = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(p.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(i.ProviderInfo_LastName_OrgName_NM103, ''))), ':', RTRIM(LTRIM(COALESCE(i.ProviderInfo_FirstName_NM104, '')))))), 2)) ,
                    S_ProviderDemo_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(p.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(i.ProviderInfo_LastName_OrgName_NM103, ''))), ':', RTRIM(LTRIM(COALESCE(i.ProviderInfo_FirstName_NM104, '')))))), 2)) ,
                    ProviderID = p.ClientProviderID ,
				NetworkID = n.ClientNetworkID ,
				CentauriNetworkID = n.CentauriNetworkID,
                    H_Network_RK = n.NetworkHashKey,
                    CentauriMemberID = m.CentauriMemberID ,
                    H_Member_RK = m.MemberHashKey ,
                    L_MemberProvider_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriProviderID, '')))))), 2)) ,
                    H_Location_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.Member_Address_N301,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CityName_N401,''))),':',RTRIM(LTRIM(COALESCE(i.Member_StateProvinceCode_N402,''))),':',RTRIM(LTRIM(COALESCE(i.Member_PostalCode_N403,'')))))),2)) ,
                    Location_BK = CONVERT(VARCHAR(157),CONCAT(i.Member_Address_N301,i.Member_CityName_N401,i.Member_StateProvinceCode_N402,i.Member_PostalCode_N403)) ,
                    L_MemberLocation_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.Member_Address_N301,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CityName_N401,''))),':',RTRIM(LTRIM(COALESCE(i.Member_StateProvinceCode_N402,''))),':',RTRIM(LTRIM(COALESCE(i.Member_PostalCode_N403,'')))))),2)) ,
                    S_MemberHICN_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_RefID3_REF02,'')))))),2)) ,
                    S_MemberHICN_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_RefID3_REF02,'')))))),2)) ,
                    S_MemberElig_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_DateTimePeriod1_DTP03, ''))), ':', RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_DateTimePeriod2_DTP03, ''))), ':', RTRIM(LTRIM(COALESCE(p.ClientProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(n.ClientNetworkID, ''))), ':', RTRIM(LTRIM(COALESCE(i.PlanLevelDetail_Payer_N102, '')))   ))), 2)) ,
                    S_MemberElig_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_DateTimePeriod1_DTP03, ''))), ':', RTRIM(LTRIM(COALESCE(i.MemberLevelDetail_DateTimePeriod2_DTP03, ''))), ':', RTRIM(LTRIM(COALESCE(p.ClientProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(n.ClientNetworkID, ''))), ':', RTRIM(LTRIM(COALESCE(i.PlanLevelDetail_Payer_N102, '')))   ))), 2)) ,
                    S_MemberDemo_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.Member_LastName_OrgName_NM103,''))),':',RTRIM(LTRIM(COALESCE(i.Member_FirstName_NM104,''))),':',RTRIM(LTRIM(COALESCE(i.Member_Gender_DMG03,''))),':',RTRIM(LTRIM(COALESCE(i.Member_DOB_DMG02,'')))  ))),2)) ,
                    S_MemberDemo_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.Member_LastName_OrgName_NM103,''))),':',RTRIM(LTRIM(COALESCE(i.Member_FirstName_NM104,''))),':',RTRIM(LTRIM(COALESCE(i.Member_Gender_DMG03,''))),':',RTRIM(LTRIM(COALESCE(i.Member_DOB_DMG02,'')))  ))),2)) ,
                    H_Contact_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER03, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER04, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER05, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER06, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER07, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER08, '')))))), 2)) ,
                    Contact_BK = CONCAT(i.Member_CommunicationNumberQualifier_PER03, CONVERT(VARCHAR(256),i.Member_CommunicationNumber_PER04), i.Member_CommunicationNumberQualifier_PER05, CONVERT(VARCHAR(256),i.Member_CommunicationNumber_PER06), i.Member_CommunicationNumberQualifier_PER07, CONVERT(VARCHAR(256),i.Member_CommunicationNumber_PER08)) ,
                    L_MemberContact_RK = UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER03, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER04, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER05, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER06, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER07, ''))), ':', RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER08, '')))))), 2)) ,
				S_Contact_834_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER03,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER04,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER05,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER06,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER07,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER08,'')))  ))),2)) ,
				S_Contact_834_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER03,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER04,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER05,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER06,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumberQualifier_PER07,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CommunicationNumber_PER08,'')))  ))),2)) ,
				LS_MemberProvider_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(p.CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(i.HealthCoverage_DateTimePeriod1_DTP03,''))) ))),2)) ,
				LS_MemberProvider_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(p.CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(i.HealthCoverage_DateTimePeriod1_DTP03,''))) ))),2)) ,
				S_Location_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(@RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(@CurrentDate,''))),':',RTRIM(LTRIM(COALESCE(i.Member_Address_N301,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CityName_N401,''))),':',RTRIM(LTRIM(COALESCE(i.Member_StateProvinceCode_N402,''))),':',RTRIM(LTRIM(COALESCE(i.Member_PostalCode_N403,'')))  ))),2)) ,
				S_Location_HashDiff = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(i.Member_Address_N301,''))),':',RTRIM(LTRIM(COALESCE(i.Member_CityName_N401,''))),':',RTRIM(LTRIM(COALESCE(i.Member_StateProvinceCode_N402,''))),':',RTRIM(LTRIM(COALESCE(i.Member_PostalCode_N403,''))) ))),2)) ,
				L_ProviderNetwork_RK = UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(p.CentauriProviderID,''))),':',RTRIM(LTRIM(COALESCE(n.CentauriNetworkID,''))) ))),2))
            FROM    CHSStaging.dbo.X12_834_RawImport i--4459
                    INNER JOIN CHSStaging.dbo.TradingPartnerFile AS t ON i.FileLevelDetail_SenderID_GS02 = t.SenderID
                                                                         AND i.FileLevelDetail_ReceiverID_GS03 = t.ReceiverID
                    INNER JOIN CHSDV.dbo.R_Client c ON t.TradingPartner = c.ClientName
                    INNER JOIN CHSDV.dbo.R_Member m ON m.ClientID = c.CentauriClientID
                                                       AND m.ClientMemberID = i.MemberLevelDetail_RefID1_REF02--4459
                    LEFT JOIN CHSDV.dbo.R_Provider p ON c.CentauriClientID = p.ClientID
                                                        AND p.ClientProviderID = dbo.ufn_parsefind(REPLACE(i.ProviderInfo_IdentificationCode_NM109, ' ', ':'), ':', 1)--4459
                    LEFT JOIN CHSDV.dbo.R_Network n ON n.ClientID = c.CentauriClientID
                                                       AND n.ClientNetworkID = RIGHT(RTRIM(i.ProviderInfo_IdentificationCode_NM109),
                                                                                     LEN(RTRIM(i.ProviderInfo_IdentificationCode_NM109)) - CHARINDEX(' ',
                                                                                                                                                RTRIM(i.ProviderInfo_IdentificationCode_NM109)));


        END TRY
        BEGIN CATCH
            THROW;
        END CATCH;
    END;
GO
