SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE VIEW [internal].[current_user_object_permissions] AS SELECT [object_type],
				 [object_id],
				 [permission_type], 
				 [sid],
				 [is_role],
				 [is_deny]
			FROM     SSISDB.[internal].[object_permissions]
			WHERE     IS_MEMBER(USER_NAME(SSISDB.[internal].[get_principal_id_by_sid]([sid])))=1
			 OR     [sid] = USER_SID (DATABASE_PRINCIPAL_ID())
GO
