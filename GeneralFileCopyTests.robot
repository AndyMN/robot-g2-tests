
*** Settings ***
Library		OperatingSystem
Library		Collections

Library		ProtocolTesterLib.py
Library		DoorTesterLib.py	${HOST}
Library		FileTesterLib.py

Variables   UserDefinedVariables.py
Resource    UserKeywords.robot


Suite Setup	CHECK IF DOORS ARE OPEN		${PROTOCOL_PORTS}
Suite Teardown	REMOVE LOCAL AND REMOTE FILES WITH NAMES CONTAINING	testfile	testo
Test Template	COPY FILE WITH CLIENT AND PROTOCOL


*** Test Cases ***
SRMCP	srmcp	srm	${LOCAL_FILE}	${REMOTE_FILE}
DCCP	dccp	gsidcap	${LOCAL_FILE}	${REMOTE_FILE}	${EXTRA_ARGUMENTS}=-A
GLOBUS	globus-url-copy	gsiftp	${LOCAL_FILE}	${REMOTE_FILE}
ARCCP	arccp	srm	${LOCAL_FILE}	${REMOTE_FILE}


*** Keywords ***

COPY FILE WITH CLIENT AND PROTOCOL
	[Arguments]	${CLIENT}	${PROTOCOL}	${LOCAL_FILE}	${REMOTE_FILE}	${EXTRA_ARGUMENTS}=${EMPTY}     ${PROTOCOL_PORT}=-1
	CREATE FILE	${LOCAL_FILE}${TEST NAME}	This is a testfile for ${TEST NAME}
	SET CLIENT	${CLIENT}
	RUN KEYWORD IF  ${PROTOCOL_PORT} < 0
	...     ${PORT}=    GET FROM DICTIONARY  ${PROTOCOL_PORTS}  ${PROTOCOL}
	...     ELSE
	...     ${PORT}=    ${PROTOCOL_PORT}
	SET PROTOCOL	${PROTOCOL}	${PORT}
	SET EXTRA ARGUMENTS	${EXTRA_ARGUMENTS}
	SET HOST	${HOST}
	COPY LOCAL FILE	${LOCAL_FILE}${TEST NAME}	${REMOTE_FILE}${TEST NAME}
	COMMAND SHOULD EXECUTE SUCCESSFULLY
	COPY REMOTE FILE	${REMOTE_FILE}${TEST NAME}	${LOCAL_FILE}${TEST NAME}1
	COMMAND SHOULD EXECUTE SUCCESSFULLY
	FILES SHOULD BE THE SAME	${LOCAL_FILE}${TEST NAME}	${LOCAL_FILE}${TEST NAME}1


REMOVE LOCAL FILES WITH NAMES CONTAINING
	[Arguments]	${FILE_NAME_ID}
	@{FILES_IN_DIR}=	LIST FILES IN DIRECTORY	${LOCAL_DIR}	pattern=${FILE_NAME_ID}*
	:FOR	${FILE}		IN	@{FILES_IN_DIR}
	\	REMOVE FILE	${FILE}

REMOVE REMOTE FILES WITH NAMES CONTAINING
	[Arguments]	${FILE_NAME_ID}
	SET CLIENT	srmls
	SET HOST	${HOST}
	${PORT}=	GET FROM DICTIONARY	${PROTOCOL_PORTS}	srm
	SET PROTOCOL	srm	${PORT}
	${FILES_IN_DIR}=	GET REMOTE FILES LIST	${REMOTE_DIR}
	${MATCHED_FILES}=	GET MATCHES	${FILES_IN_DIR}		*${FILE_NAME_ID}*
	:FOR 	${FILE}		IN	@{MATCHED_FILES}
	\	REMOVE FILE WITH CLIENT AND PROTOCOL	srmrm	srm	${FILE}	

REMOVE LOCAL AND REMOTE FILES WITH NAMES CONTAINING
	[Arguments]	${LOCAL_FILE_ID}	${REMOTE_FILE_ID}
	REMOVE LOCAL FILES WITH NAMES CONTAINING	${LOCAL_FILE_ID}
	REMOVE REMOTE FILES WITH NAMES CONTAINING	${REMOTE_FILE_ID}
