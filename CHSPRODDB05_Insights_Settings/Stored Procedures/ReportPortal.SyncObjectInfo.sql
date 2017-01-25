SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/24/2015
-- Description:	Used by the Report Portal application, updates the xml collected about object XML data pulled from SQL Server or Reporting Services.
-- =============================================
CREATE PROCEDURE [ReportPortal].[SyncObjectInfo]
(
	@Info xml,
	@RptObjID smallint
)
AS
BEGIN
	SET NOCOUNT ON;

    IF EXISTS(SELECT TOP 1 1 FROM ReportPortal.[Objects] WHERE RptObjID = @RptObjID)
		BEGIN;
			BEGIN TRANSACTION TSyncObjectInfo;

			IF EXISTS(SELECT TOP 1 1 FROM ReportPortal.ObjectInfo WHERE RptObjID = @RptObjID)
				BEGIN;
					UPDATE	ReportPortal.ObjectInfo
					SET		Info = @Info,
							LastUpdatedDate = GETDATE()
					WHERE	RptObjID = @RptObjID AND
							LastUpdatedDate < DATEADD(hh, -23, GETDATE()); --Only update the info if current info is older than ~1 day.
				END;
			ELSE
				BEGIN;
					INSERT INTO ReportPortal.ObjectInfo
							(Info,
							RptObjID)
					VALUES	(@Info,
							@RptObjID);
				END;

			IF @@ROWCOUNT > 0
				BEGIN;
					SELECT * INTO #ObjectInfoParameters FROM ReportPortal.GetObjectInfoParameters(@RptObjID);

					MERGE ReportPortal.ObjectParameters AS t
					USING	(
								SELECT	HasDefaultValue,
										ParameterDataType,
                                        ParameterName,
                                        ParameterPrompt,
                                        RptObjID
								FROM	#ObjectInfoParameters
								WHERE	IsVisible = 1
							) AS s
							(
								HasDefaultValue,
								ParameterDataType,
								ParameterName,
								ParameterPrompt,
								RptObjID
							)
							ON (t.RptObjID = s.RptObjID AND t.ParamName = s.ParameterName)
					WHEN MATCHED
					THEN UPDATE SET t.DefaultValueDescr = CASE WHEN s.HasDefaultValue = 1 THEN '(Calculated)' END,
									t.Descr = s.ParameterPrompt,
									t.HasDefaultValue = s.HasDefaultValue,
									t.ParamDataType = s.ParameterDataType
					WHEN NOT MATCHED BY SOURCE AND t.RptObjID = @RptObjID
					THEN DELETE
					WHEN NOT MATCHED BY TARGET
					THEN INSERT (DefaultValueDescr, 
								Descr, 
								HasDefaultValue,
								ParamDataType,
								ParamName,
								RptObjID)
						 VALUES (CASE WHEN s.HasDefaultValue = 1 THEN '(Calculated)' END,
								s.ParameterPrompt,
								s.HasDefaultValue,
								s.ParameterDataType,
								s.ParameterName,
								s.RptObjID);
									
				END;

			COMMIT TRANSACTION TSyncObjectInfo;
		END;
END
GO
GRANT EXECUTE ON  [ReportPortal].[SyncObjectInfo] TO [PortalApp]
GO
