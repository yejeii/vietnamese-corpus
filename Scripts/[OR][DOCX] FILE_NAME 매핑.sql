USE vncsim;

-- CREATE TABLE load_vnc_org_lst_sim_20230905 LIKE load_vnc_org_lst_sim;
-- CREATE TABLE load_vnc_file_list_sim_20230905 like load_vnc_file_list_sim;
-- CREATE TABLE load_vnc_file_docx_sim_20230905 LIKE load_vnc_file_docx_sim;

-- ALTER TABLE load_vnc_org_lst_sim_20230905
-- AUTO_INCREMENT=1;


-- 파이썬 작업 후 ----------------------------------------

-- 1. 각 테이블 인서트 현황 파악
-- 작업자, 주제분류, 작업날짜로 그룹핑하여 3T 전체 확인
-- 확인 대상 : 작업자별 작업 개수, 전체 중복 제외한 FILE_NAME 수, 집계
-- 레코드 ROW 개수는 테이블 수(3)*작업자 수만큼 나와야 정상.
SELECT "엑셀 T" AS "TABLE"
	, WORKER_ID
	, LEFT(FILE_NAME, 2) "TOPIC_CD"
	, COUNT(*) "행 수"
	, COUNT(DISTINCT COL_PK) "DISTINCT 확인" 
	, SUM(COUNT(*)) OVER() AS "각 테이블 행 총합"
FROM load_vnc_org_lst_sim_20230905
GROUP BY WORKER_ID, LEFT(FILE_NAME, 2), JOB_YMD
UNION 
SELECT "파일 T" 
	, WORKER_ID
	, LEFT(FILE_NAME, 2) "TOPIC_CD"
	, COUNT(*) "행 수"
	, COUNT(DISTINCT FILE_NAME)
	, SUM(COUNT(*)) OVER()
FROM load_vnc_file_list_sim_20230905 
GROUP BY WORKER_ID, LEFT(FILE_NAME, 2), WORKYMD
UNION 
SELECT "문서 T"
	, mid(FILE_NAME, 4, 5) "WORKER_ID"
	, left(FILE_NAME, 2)
	, COUNT(*) "행 수"
	, COUNT(DISTINCT FILE_NAME)
	, SUM(COUNT(*)) OVER()
FROM load_vnc_file_docx_sim_20230905
GROUP BY mid(FILE_NAME, 4, 5), left(FILE_NAME, 2), mid(FILE_NAME, 10, 8)
ORDER BY 2, 1;	-- 작업자, TABLE명 정렬


-- 2. FILE_NAME 길이 확인
SELECT Length(COL_PK)
FROM load_vnc_org_lst_sim_20230905
GROUP BY length(COL_PK);

SELECT Length(FILE_NAME)
FROM load_vnc_file_list_sim_20230905
GROUP BY length(FILE_NAME);

SELECT Length(FILE_NAME)
FROM load_vnc_file_docx_sim_20230905
GROUP BY length(FILE_NAME);

-- 22가 아닌 FILE_NAME 수정
SELECT FILE_NAME
FROM load_vnc_file_list_sim_20230905
WHERE LENGTH(FILE_NAME) = 23

-- UPDATE load_vnc_file_list_sim_20230905
SET FILE_NAME = CONCAT(substring_index(FILE_NAME, '_', 3), '_', RIGHT(FILE_NAME, 4))
WHERE LENGTH(FILE_NAME) = 23;

SELECT DISTINCT FILE_NAME 
FROM load_vnc_file_docx_sim_20230905
WHERE LENGTH(FILE_NAME) = 23

-- UPDATE load_vnc_file_docx_sim_20230905
SET FILE_NAME = CONCAT(substring_index(FILE_NAME, '_', 3), '_', RIGHT(FILE_NAME, 4))
WHERE LENGTH(FILE_NAME) = 23;


-- 3. 세 테이블에서 공통된 파일명만 뽑아서 각 테이블 맞추기
DROP TABLE IF EXISTS temp_20230905_3t_match;
CREATE TABLE IF NOT EXISTS temp_20230905_3t_match
SELECT DISTINCT a.COL_PK	-- SELECT count(*)	-- 1391
FROM load_vnc_org_lst_sim_20230905 a 
JOIN load_vnc_file_list_sim_20230905 b
ON a.COL_PK = b.FILE_NAME 
JOIN (SELECT DISTINCT FILE_NAME FROM load_vnc_file_docx_sim_20230905) c
ON b.FILE_NAME = c.FILE_NAME;

CREATE INDEX temp_20230905_3t_match_COL_PK_IDX USING BTREE ON temp_20230905_3t_match (COL_PK);

-- 공통된 파일명 외의 기타 파일명 확인 후 세 테이블에서 각각 삭제
SELECT * 	-- SELECT count(*)		-- DELETE 
FROM load_vnc_org_lst_sim_20230905
WHERE COL_PK NOT IN 
	(SELECT COL_PK FROM temp_20230905_3t_match);	

SELECT *	-- SELECT count(*)	-- DELETE 
FROM load_vnc_file_list_sim_20230905
WHERE FILE_NAME NOT IN 	
	(SELECT COL_PK FROM temp_20230905_3t_match);	
	
SELECT *	-- SELECT count(DISTINCT FILE_NAME)		-- SELECT count(*)	-- DELETE 
FROM load_vnc_file_docx_sim_20230905
WHERE FILE_NAME NOT IN 
	(SELECT COL_PK FROM temp_20230905_3t_match)	


-- 4. 세 개의 테이블 갯수 확인
-- COUNT(*)와 COUNT(DISTINCT FILE_NAME) 개수가 맞아야 함!
SELECT "엑셀 T" AS "TABLE", COUNT(*), COUNT(DISTINCT COL_PK)
FROM load_vnc_org_lst_sim_20230905
UNION 
SELECT "파일 T", COUNT(*), COUNT(DISTINCT FILE_NAME)
FROM load_vnc_file_list_sim_20230905
UNION
SELECT "문서 T", COUNT(*), COUNT(DISTINCT FILE_NAME)		
FROM load_vnc_file_docx_sim_20230905;


-- 5. 원시 테이블에서의 중복 URL 제거
-- -- 1. 엑셀 테이블에서 중복 URL 확인
SELECT DAT_SRC	
	, COUNT(*)	"그룹마다 중복 개수" 
	, SUM(COUNT(DISTINCT DAT_SRC)) OVER () AS "URL 총 수"	
	, SUM(COUNT(*)) OVER() AS "중복 건수" 	
FROM load_vnc_org_lst_sim_20230905
GROUP BY DAT_SRC 
HAVING count(DAT_SRC) > 1;

-- -- 2. 중복 url만 모은 임시 excel 테이블 생성
DROP TABLE temp_org_lst_20230905_dupli_url;
CREATE TABLE IF NOT EXISTS temp_org_lst_20230905_dupli_url		
	(	
		SELECT a.IDX, a.COL_PK, a.DAT_SRC, a.WORKER_ID, a.JOB_YMD, a.SEQ, a.TITLE, a.PUB_YMD, 	
		ROW_NUMBER() over(PARTITION BY a.DAT_SRC ORDER BY a.IDX) AS "DUPLI_RANK"	
		-- SELECT count(*)	-- 4
		FROM load_vnc_org_lst_sim_20230905 a,
			(
				SELECT DAT_SRC	
				FROM load_vnc_org_lst_sim_20230905
				GROUP BY DAT_SRC
				HAVING count(DAT_SRC) > 1 
			) b
		WHERE a.DAT_SRC = b.DAT_SRC
	)

-- -- 3. 첫 번째가 아닌 중복 행들 확인(3T에서 삭제될 파일명 개수)
SELECT count(*)	-- 2
-- SELECT COL_PK 
FROM temp_org_lst_20230905_dupli_url 
WHERE DUPLI_RANK <> 1	

-- -- 4. 위에 해당하는 행을 기준으로 3T에서 모두 제거
-- SELECT *	
SELECT count(*)	-- DELETE 
FROM load_vnc_org_lst_sim_20230905  
WHERE COL_PK IN (SELECT COL_PK FROM temp_org_lst_20230905_dupli_url WHERE DUPLI_RANK <> 1)

-- SELECT *	
SELECT count(*)	-- DELETE 
FROM load_vnc_file_list_sim_20230905 
WHERE FILE_NAME IN (SELECT COL_PK FROM temp_org_lst_20230905_dupli_url WHERE DUPLI_RANK <> 1)

-- SELECT count(*)		-- 20 			
SELECT count(DISTINCT FILE_NAME)	-- 2		-- DELETE 
FROM load_vnc_file_docx_sim_20230905 
WHERE FILE_NAME IN (SELECT COL_PK FROM temp_org_lst_20230905_dupli_url WHERE DUPLI_RANK <> 1)

-- -- 5. 행 개수 확인
SELECT "엑셀 T" AS "TABLE", COUNT(*), COUNT(DISTINCT COL_PK)
FROM load_vnc_org_lst_sim_20230905
UNION 
SELECT "파일 T", COUNT(*), COUNT(DISTINCT FILE_NAME)
FROM load_vnc_file_list_sim_20230905
UNION
SELECT "문서 T", COUNT(*), COUNT(DISTINCT FILE_NAME)		
FROM load_vnc_file_docx_sim_20230905;


-- 6. 납품 테이블과 비교, 존재 URL 제거
DROP TABLE IF EXISTS temp_org_20230905_dupli_url;
CREATE TABLE temp_org_20230905_dupli_url
SELECT COL_PK
FROM load_vnc_org_lst_sim_20230905
WHERE DAT_SRC IN (
							SELECT DAT_SRC
							FROM vnc.load_vnc_org_lst_sim
						)

-- 확인 후 삭제
SELECT count(*)		-- DELETE 
FROM load_vnc_org_lst_sim_20230905
WHERE COL_PK IN (SELECT COL_PK FROM temp_org_20230905_dupli_url)

SELECT count(*)		-- DELETE 
FROM load_vnc_file_list_sim_20230905
WHERE FILE_NAME IN (SELECT COL_PK FROM temp_org_20230905_dupli_url)

-- SELECT count(*)	-- 206082
SELECT count(DISTINCT FILE_NAME)	-- DELETE 
FROM load_vnc_file_docx_sim_20230905
WHERE FILE_NAME IN (SELECT COL_PK FROM temp_org_20230905_dupli_url)

-- 행 개수 확인
SELECT "엑셀 T" AS "TABLE", COUNT(*), COUNT(DISTINCT COL_PK)
FROM load_vnc_org_lst_sim_20230905
UNION 
SELECT "파일 T", COUNT(*), COUNT(DISTINCT FILE_NAME)
FROM load_vnc_file_list_sim_20230905
UNION
SELECT "문서 T", COUNT(*), COUNT(DISTINCT FILE_NAME)		
FROM load_vnc_file_docx_sim_20230905;


-- 7. 마지막 확인
-- -- 1. 파일명 확인
SELECT *
FROM load_vnc_org_lst_sim_20230905
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1

SELECT *
FROM load_vnc_file_list_sim_20230905
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1


-- 8. 임시 테이블 삭제
-- DROP TABLE IF EXISTS temp_20230905_3t_match;
-- DROP TABLE IF EXISTS temp_org_lst_20230905_dupli_url;