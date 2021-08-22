/*

16199 Property_Dim Stored Procedure Update to Include AcquisitionDate And DispositionDate
	Where is the stored procedure?
	
16197 RCS_3NF Build Update To Include AcquisitionDate And DispositionDate on BRH_PROPERTY Table
	\DataEngineering\Archive\ModelBuild\RCS\3NF_Build__SQL.sql
		CREATE TABLE rcs_3nf.BRH_PROPERTY_NEW
	\DataEngineering\ModelBuild\RCS\3NF_Build_Blend.py
		query = f"DROP TABLE IF EXISTS {target_schema}.BRH_PROPERTY_NEW"
	\DataEngineering\ModelBuild\RCS\3NF_Build_old.py
		query = f"DROP TABLE IF EXISTS {target_schema}.BRH_PROPERTY_NEW"
		
16198 BRH_3NF Build Update To Include AcquisitionDate And DispositionDate on the STR_PROPERTY Table
		\DataEngineering\Archive\ModelBuild\BRH\3NF_Build__SQL.sql
			DROP TABLE IF EXISTS brh_3nf.STR_PROPERTY_NEW;
		\DataEngineering\ModelBuild\BRH\3NF_Build_old.py
			query = f"DROP TABLE IF EXISTS {target_schema}.STR_PROPERTY_NEW"
			
16201 Update BREIT_RPT Table & Stored Procedure to Include Property_Dim.AcquisitionDate
		Where is the stored procedure?

16441 Assess current Asset_Review script being executed in Snowflake and update as needed
	CREATED STORED PROC [RCS_DW].[usp_PersistFinancialMappings]
		POPULATING [RCS_DW].[tbl_ReportLineCalcGroupMapping] TABLE
		
16463 Improve view performance for FACT table
	this task cannot be completed until #16441  is done but work on this task can start now
	
15644 Build the Asset_Review table to the RCS_DW schema in Snowflake
	?
	Building of the table and the stored proc to load table
	refresh daily with the RCS_DW schema

15645 Add the "Asset_Review" object to the list of objects to be propagated to Snowflake
	?
	Update State Database

*/
