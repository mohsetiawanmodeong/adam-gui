USE [gbc_mrcapps]
GO

/****** Object:  StoredProcedure [dbo].[mrcFMIACPMerge]    Script Date: 25/03/2025 07:36:12 ******/
DROP PROCEDURE [dbo].[mrcFMIACPMerge]
GO

/****** Object:  StoredProcedure [dbo].[mrcFMIACPMerge]    Script Date: 25/03/2025 07:36:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[mrcFMIACPMerge](
@vmachine_name as nvarchar(64), @vstart_time as datetimeoffset(3), @vcategory as nvarchar(64), @vtype as nvarchar(64), @vmeasurement as nvarchar(64), @vvalue as nvarchar(64),
@vUNIQUE_CONST as nvarchar(128))
AS
BEGIN
MERGE INTO FMIACP USING ( VALUES (@vmachine_name, @vstart_time, @vcategory, @vtype, @vmeasurement, @vvalue)) I 
(machine_name, start_time, [category], [type], [measurement], [value])
ON (FMIACP.[UNIQUE_CONST]= @vUNIQUE_CONST) 
WHEN MATCHED AND (I.machine_name <> @vmachine_name OR I.[category] <> @vcategory OR I.[measurement] <> @vmeasurement OR I.[value] <> @vvalue) THEN
UPDATE SET machine_name=@vmachine_name, [category]=@vcategory,[measurement]=@vmeasurement,[value]=@vvalue, LAST_UPDATE=SYSDATETIMEOFFSET()
-- WHEN NOT MATCHED THEN INSERT ( machine_name, start_time, [category], [type], [measurement], [value],LAST_UPDATE ) 
-- VALUES (@vmachine_name, @vstart_time, @vcategory, @vtype, @vmeasurement, @vvalue, SYSDATETIMEOFFSET());
WHEN NOT MATCHED THEN INSERT (machine_name, start_time, [category], [type], [measurement], [value], [UNIQUE_CONST], LAST_UPDATE) 
VALUES (@vmachine_name, @vstart_time, @vcategory, @vtype, @vmeasurement, @vvalue, @vUNIQUE_CONST, SYSDATETIMEOFFSET());
END;
GO





USE [gbc_mrcapps]
GO
 
/****** Object:  Table [dbo].[CMDTELEMETRY]    Script Date: 18/03/2025 13:04:08 ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [dbo].[FMIACP](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MACHINE_NAME] [nvarchar](64) NULL,
	[START_TIME] [datetimeoffset](3) NULL,
	[CATEGORY] [nvarchar](64) NULL,
	[TYPE] [nvarchar](64) NULL,
	[MEASUREMENT] [nvarchar](64) NULL,
	[VALUE] [nvarchar](256) NULL,
	[UNIQUE_CONST]  AS (concat(datediff(second,CONVERT([datetime],'1970-01-01 00:00:00.000',(20)),[START_TIME]),'-',[MACHINE_NAME],'-',[TYPE])) PERSISTED NOT NULL,
	[LAST_UPDATE] [datetimeoffset](3) NULL
) ON [PRIMARY]
GO
 
ALTER TABLE [dbo].[FMIACP] ADD  DEFAULT (getdate()) FOR [LAST_UPDATE]
GO