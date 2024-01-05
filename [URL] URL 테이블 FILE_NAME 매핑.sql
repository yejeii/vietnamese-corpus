USE vncsim;

-- SET @job_ymd = '20231029'

-- 1. 20231029 작업 테이블 생성, idx PK 처리 및 AI 처리하기!!	
-- CREATE TABLE url_excel_list_from_20231029 LIKE url_excel_list_from_20231025;
-- CREATE TABLE url_scrap_list_from_20231029 LIKE url_scrap_list_from_20231025;
-- CREATE TABLE url_scrap_txt_from_20231029 LIKE url_scrap_txt_from_20231025;


-- 2. 파이썬 작업 후 확인
-- -- 1. url_excel_list(작업자 엑셀 파일)
-- 날짜별, 작업자별 URL 개수 확인
SELECT JOB_YMD, WORKER_ID, count(DAT_SRC) "URL 개수"	
FROM vncsim.url_excel_list_from_20231029 
-- WHERE JOB_YMD  = @job_ymd
GROUP BY WORKER_ID, JOB_YMD
ORDER BY JOB_YMD, WORKER_ID

-- TOPIC_CD 확인
SELECT TOPIC_CD,  substring_index(DAT_SRC , '/', 3) "DAT_SRC" 
FROM vncsim.url_excel_list_from_20231029 
GROUP BY TOPIC_CD, substring_index(DAT_SRC , '/', 3)
-- 03	https://kinhtemoitruong.vn

-- col_pk 길이 확인
SELECT length(file_name)
FROM vncsim.url_excel_list_from_20231029 
GROUP BY length(FILE_NAME)

-- -- 2. 크롤링 테이블 확인
-- 날짜별, 작업자별 URL 개수 확인
SELECT JOB_YMD, WORKER_ID, count(DAT_SRC) "URL 개수"
FROM vncsim.url_scrap_list_from_20231029
-- WHERE JOB_YMD  = @job_ymd
GROUP BY WORKER_ID, JOB_YMD
ORDER BY JOB_YMD, WORKER_ID

SELECT SCRAP_FILE_NAME, count(SCRAP_FILE_NAME)
FROM url_scrap_list_from_20231029 
GROUP BY SCRAP_FILE_NAME;

SELECT FILE_NAME,  count(DISTINCT DAT_SRC) "URL 개수"
FROM  vncsim.url_scrap_txt_from_20231029 
-- WHERE FILE_NAME LIKE concat('%',@job_ymd,'%')
GROUP BY FILE_NAME
ORDER BY FILE_NAME ASC 

	
-- 3. 각 테이블별 행 개수 확인
-- select count(*)
SELECT COUNT(DISTINCT FILE_NAME)
FROM vncsim.url_excel_list_from_20231029;

-- select count(*)
SELECT COUNT(DISTINCT dat_src)
FROM vncsim.url_scrap_list_from_20231029 
-- WHERE JOB_YMD  = @job_ymd
-- 12452

-- select count(*)	
SELECT count(DISTINCT DAT_SRC)	-- 12452(중복을 하나로 처리)
FROM vncsim.url_scrap_txt_from_20231029 
-- WHERE FILE_NAME LIKE concat('%',@job_ymd,'%')


-- 4. 중복되는 URL 확인 후 제거
-- -- 1. 각 테이블에서 중복되는 URL 확인 후 테이블 생성, 복사
SELECT DAT_SRC, FILE_NAME 	-- SELECT count(*)	
FROM url_excel_list_from_20231029 
GROUP BY DAT_SRC
HAVING count(DAT_SRC) > 1

-- 중복 url만 모은 excel 테이블 생성
DROP TABLE IF EXISTS url_excel_list_from_20231029_dupli_url;
CREATE TABLE url_excel_list_from_20231029_dupli_url		
(SELECT uslf.IDX, uslf.COL_PK, uslf.DAT_SRC, uslf.WORKER_ID, uslf.JOB_YMD, uslf.SEQ, uslf.TITLE, uslf.PUB_YMD, 	
		RANK() over(PARTITION BY uslf.DAT_SRC ORDER BY uslf.WORKER_ID, uslf.JOB_YMD, SEQ) AS "DUPLI_RANK"	
		-- SELECT count(*)	
FROM url_excel_list_from_20231029  uslf,
	(SELECT DAT_SRC	
	FROM url_excel_list_from_20231029 
	GROUP BY DAT_SRC
	HAVING count(DAT_SRC) > 1 ) a
WHERE uslf.DAT_SRC = a.DAT_SRC);

-- 확인
SELECT *
-- SELECT count(*)	
FROM url_excel_list_from_20231029_dupli_url
WHERE DUPLI_RANK <> 1;

-- 중복 url만 모은 excel 테이블에서 RANK가 2이상인 행과 scrap_list 조회하여 scrap_list 중복 테이블 생성
DROP TABLE IF EXISTS url_scrap_list_from_20231029_dupli_url;
CREATE TABLE url_scrap_list_from_20231029_dupli_url
(SELECT uslf.IDX, uelf.col_pk, uslf.SCRAP_FILE_NAME, 
		uslf.WORKER_ID, uslf.JOB_YMD, uslf.SEQ, uslf.DAT_SRC, uslf.TITLE, uelf.DUPLI_RANK  	
		-- SELECT count(*)	
FROM url_scrap_list_from_20231029 uslf 
INNER JOIN url_excel_list_from_20231029_dupli_url uelf 
ON uslf.DAT_SRC = uelf.DAT_SRC 
WHERE uelf.dupli_rank > 1
-- AND uelf.JOB_YMD = @job_ymd
AND uslf.WORKER_ID = uelf.WORKER_ID 
AND uslf.JOB_YMD = uelf.JOB_YMD );

SELECT *
FROM url_scrap_list_from_20231029_dupli_url

ALTER TABLE url_scrap_list_from_20231019_07_dupli_url ADD COLUMN DEL_RANK int(1) DEFAULT 0;

UPDATE url_scrap_list_from_20231017_dupli_url a
INNER JOIN (SELECT IDX , RANK() OVER(PARTITION BY DAT_SRC ORDER BY WORKER_ID, JOB_YMD, SEQ) "del_rank"
		FROM url_scrap_list_from_20231017_dupli_url) b
ON a.IDX = b.IDX 
SET a.del_rank = b.del_rank;



-- rank 2이상인 url만 모은 scrap_list 테이블에서 scrap_txt 조회하여 scrap_txt 중복 테이블 생성
DROP TABLE IF EXISTS url_scrap_txt_from_20231029_dupli_url;
CREATE TABLE url_scrap_txt_from_20231029_dupli_url	-- 1995
(SELECT DISTINCT ustf.IDX, a.col_pk, 
		ustf.FILE_NAME, a.worker_id, a.job_ymd, 
		ustf.DAT_SRC, ustf.TITLE , ustf.DAT_TXT, a.DUPLI_RANK -- , a.DEL_RANK
		-- SELECT count(distinct A.COL_PK)	-- 57
		-- SELECT DISTINCT A.COL_PK
		-- DELETE ustf	
FROM url_scrap_txt_from_20231029 ustf 
JOIN url_scrap_list_from_20231029_dupli_url a
ON ustf.DAT_SRC = a.DAT_SRC
-- WHERE a.DEL_RANK != 1
WHERE ustf.FILE_NAME = a.scrap_file_name 
AND ustf.TITLE = a.title
-- GROUP BY ustf.DAT_SRC	-- COUNT할 때는 주석, SELECT할 때는 주석 해제, INSERT할 때는 주석
);

SELECT count(*)	-- 66
FROM url_scrap_list_from_20231029_dupli_url;

SELECT count(DISTINCT col_pk)	-- 57
FROM url_scrap_txt_from_20231029_dupli_url;

-- SELECT count(*)	-- 1995
SELECT count(DISTINCT col_pk)	-- 57
FROM url_scrap_txt_from_20231029_dupli_url;	

-- url_scrap_list_dupli 테이블에 있는 col_pk가 url_excel_dupli(rank > 1) 에 있는 col_pk인지 확인(삭제대상이 맞는지 확인)
SELECT count(DISTINCT a.dat_src)	-- 53
FROM url_scrap_list_from_20231029_dupli_url a
INNER JOIN url_excel_list_from_20231029_dupli_url b
ON a.col_pk = b.col_pk;

SELECT count(DISTINCT a.dat_src)	-- 0
FROM url_scrap_list_from_20231029_dupli_url a
LEFT OUTER JOIN url_excel_list_from_20231029_dupli_url b
ON a.col_pk = b.col_pk
WHERE a.idx IS NULL;

-- url_scrap_txt_dupli 테이블에 있는 col_pk가 url_excel_dupli(rank > 1) 에 있는 col_pk인지 확인(삭제대상이 맞는지 확인)
SELECT count(DISTINCT a.dat_src)	-- 53
FROM url_scrap_txt_from_20231029_dupli_url a
INNER JOIN url_excel_list_from_20231029_dupli_url b
ON a.col_pk = b.col_pk;

SELECT count(DISTINCT a.dat_src)
FROM url_scrap_txt_from_20231029 _dupli_url a
LEFT OUTER JOIN url_excel_list_from_20231029 _dupli_url b
ON a.col_pk = b.col_pk
WHERE a.COL_PK IS NULL;
-- X
-- 하나의 URL이 중복 된 개수가 2개 이상이라 그런 것.



-- -- 2. 중복되는 URL 삭제(excel, scrap_list, scrap_txt) (위의 코드와 동일)
SELECT *	-- SELECT count(*)	-- 62
FROM url_excel_list_from_20231029_dupli_url uslfdu
WHERE dupli_rank != 1
-- AND JOB_YMD = @job_ymd

-- 삭제
SELECT *	
-- SELECT count(*)	-- 62
-- DELETE uelf
FROM url_excel_list_from_20231029  uelf
INNER JOIN url_excel_list_from_20231029_dupli_url dupli
ON uelf.COL_PK = dupli.col_pk
WHERE dupli.dupli_rank != 1
AND uelf.IDX = dupli.idx

-- 삭제
SELECT uslf.IDX, uelf.col_pk, uslf.SCRAP_FILE_NAME, 
		uslf.WORKER_ID, uslf.JOB_YMD, uslf.SEQ, uslf.DAT_SRC, uslf.TITLE, uelf.DUPLI_RANK  -- , uelf.DEL_RANK
		-- SELECT count(*)	-- 66
		-- DELETE uslf
FROM url_scrap_list_from_20231029  uslf 
INNER JOIN url_scrap_list_from_20231029_dupli_url uelf 
ON uslf.IDX = uelf.IDX 
WHERE uelf.dupli_rank != 1
-- AND uelf.DEL_RANK != 1
AND uslf.WORKER_ID = uelf.WORKER_ID 
AND uslf.JOB_YMD = uelf.JOB_YMD

-- 삭제
SELECT ustf.IDX, a.col_pk, 
		ustf.FILE_NAME, a.worker_id, a.job_ymd, 
		ustf.DAT_SRC, ustf.TITLE , ustf.DAT_TXT, a.DUPLI_RANK 	
		-- SELECT  count(*)		-- 1995
		-- select count(distinct ustf.dat_src)	-- 53
		-- DELETE ustf	
FROM url_scrap_txt_from_20231029  ustf 
JOIN url_scrap_txt_from_20231029_dupli_url a
ON ustf.IDX  = a.IDX 
WHERE ustf.DAT_SRC = a.DAT_SRC  
AND ustf.FILE_NAME = a.FILE_NAME  
AND ustf.TITLE = a.title



-- 4. 세 개의 테이블 갯수 확인
select count(*)
FROM url_excel_list_from_20231029  uel 
-- WHERE JOB_YMD  = @job_ymd


select count(*)
FROM url_scrap_list_from_20231029 
-- WHERE JOB_YMD  = @job_ymd


select count(*)	-- SELECT count(distinct dat_src)
FROM url_scrap_txt_from_20231029 
-- WHERE FILE_NAME LIKE concat('%',@job_ymd,'%')



SELECT *
FROM url_excel_list_from_20231029
GROUP BY DAT_SRC 
HAVING count(DAT_SRC) > 1

SELECT *
FROM url_scrap_list_from_20231029
GROUP BY DAT_SRC 
HAVING count(DAT_SRC) > 1



-- 5. 세 개의 테이블 excel 테이블 기준으로 file_name 맞추기
-- -- 1. excel 테이블 file_name nan 확인
SELECT *
FROM url_excel_list_from_20231029 
WHERE FILE_NAME = 'nan'
-- X

SELECT *
FROM url_excel_list_from_20231029 
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1
-- X

SELECT length(pub_ymd)
FROM url_excel_list_from_20231029 
GROUP BY length(PUB_YMD)

-- 나중에 파일명 맞추고 나서 PUB_YMD 업데이트 처리
SELECT *
FROM url_excel_list_from_20231029 
WHERE length(PUB_YMD) = 3



-- -- 2. url_scrap_list 테이블 FILE_NAME 매핑
-- -- 아래 쿼리 실행 후 인덱스 및 PK 설정
UPDATE url_scrap_list_from_20231029  usl		
INNER JOIN url_excel_list_from_20231029  uel
ON uel.DAT_SRC = usl.DAT_SRC 
SET usl.FILE_NAME = uel.FILE_NAME
WHERE usl.JOB_YMD = uel.JOB_YMD
AND usl.WORKER_ID = uel.WORKER_ID
-- 15477

-- 각 테이블에서 pub_ymd랑 title 인덱스 잡은 후 업데이트
UPDATE url_excel_list_from_20231029  uel	
INNER JOIN url_scrap_list_from_20231029  usl
ON uel.FILE_NAME = usl.FILE_NAME 
SET uel.TITLE = usl.TITLE,
	uel.PUB_YMD = usl.PUB_DATE
WHERE uel.TITLE <> usl.TITLE 
OR uel.PUB_YMD <> usl.PUB_DATE;
-- 



-- -- 3. url_scrap_txt 테이블 FILE_NAME 매핑
UPDATE url_scrap_txt_from_20231029   ust		
INNER JOIN url_scrap_list_from_20231029   usl
ON ust.DAT_SRC = usl.DAT_SRC 
SET ust.FILE_NAME = usl.FILE_NAME
WHERE ust.DAT_SRC = usl.DAT_SRC
AND ust.FILE_NAME = usl.SCRAP_FILE_NAME;
-- 351270




-- 6. 크롤링 테이블 file_name 확인
SELECT length(file_name)
FROM url_excel_list_from_20231029 
GROUP BY length(FILE_NAME)
-- 22

SELECT length(file_name)
FROM url_scrap_list_from_20231029 
GROUP BY length(FILE_NAME)
-- 22

SELECT length(file_name)
FROM url_scrap_txt_from_20231029 
GROUP BY length(FILE_NAME)
-- 22

SELECT *
FROM url_scrap_txt_from_20231029 
WHERE FILE_NAME IS NULL;


SELECT count(*)
FROM url_scrap_txt_from_20231029 
WHERE FILE_NAME IS NULL;
-- 0

SELECT *
FROM url_excel_list_02_0912_0913
WHERE FILE_NAME IS NULL 
OR DAT_SRC IN (SELECT DAT_SRC 
				FROM url_scrap_list_02_0912_0913
				WHERE FILE_NAME IS NULL)
-- NONE

SELECT *	-- DELETE
FROM url_scrap_list_from_20231012
WHERE FILE_NAME IS NULL
-- NONE

SELECT *	-- SELECT COUNT(*) -- 49 -- DELETE 
FROM url_scrap_txt_02_0912_0913
WHERE DAT_SRC IN (SELECT DAT_SRC 
					FROM url_scrap_list_02_0912_0913
					WHERE FILE_NAME IS NULL)
OR FILE_NAME IS NULL
GROUP BY DAT_SRC 


-- UPDATE url_excel_list_02_0912_0913
SET DAT_SRC = concat("https://", DAT_SRC)
WHERE DAT_SRC NOT LIKE 'https://%';
-- 365

-- 7. 세 테이블에서 공통된 파일명만 뽑아서 각 테이블 맞추기
DROP TABLE url_excel_list_from_20231029_3t_match;
CREATE TABLE url_excel_list_from_20231029_3t_match
SELECT DISTINCT a.COL_PK	-- SELECT count(*)	
FROM url_excel_list_from_20231029  a 
JOIN url_scrap_list_from_20231029  b
ON a.COL_PK = b.FILE_NAME 
JOIN (SELECT DISTINCT FILE_NAME FROM url_scrap_txt_from_20231029 ) c
ON b.FILE_NAME = c.FILE_NAME;
-- 15477

CREATE INDEX url_excel_list_from_20231029_3t_match_COL_PK_IDX USING BTREE ON vncsim.url_excel_list_from_20231029_3t_match (COL_PK);

-- 공통된 파일명 외의 기타 파일명 확인 후 세 테이블에서 각각 삭제
SELECT * 	-- SELECT count(*)		-- DELETE 
FROM url_excel_list_from_20231029 
WHERE COL_PK NOT IN 
	(SELECT COL_PK FROM url_excel_list_from_20231029_3t_match);	
-- 1

SELECT *	-- SELECT count(*)	-- DELETE 
FROM url_scrap_list_from_20231029 
WHERE FILE_NAME NOT IN 	-- NOT이라서 인덱스 안타고 전체로 돎...
	(SELECT COL_PK FROM url_excel_list_from_20231029_3t_match);	
-- 0

SELECT *	-- SELECT count(DISTINCT FILE_NAME)	
FROM url_scrap_txt_from_20231029 
WHERE FILE_NAME NOT IN 
	(SELECT COL_PK FROM url_excel_list_from_20231029_3t_match)	
-- 0	



-- 8. 세 개의 테이블 갯수 확인
-- COUNT(*)와 COUNT(DISTINCT FILE_NAME) 개수가 맞아야 함!
-- SELECT COUNT(*)
select count(DISTINCT FILE_NAME)
FROM url_excel_list_from_20231029 

-- SELECT COUNT(*)
select count(DISTINCT FILE_NAME)
FROM url_scrap_list_from_20231029 
-- WHERE JOB_YMD  = @job_ymd
-- 12452

SELECT count(*)	
-- SELECT count(distinct file_name)		-- 12452
FROM url_scrap_txt_from_20231029 ;
-- 1241187



-- load_vnc_org_lst_sim과 비교
CREATE TABLE load_vnc_org_lst_sim_20231029_dupli_url_org
SELECT *	-- select count(*) 	-- 318
FROM url_excel_list_from_20231029
WHERE DAT_SRC IN (
SELECT dat_src
FROM vnc.load_vnc_org_lst_sim)

SELECT count(*)		-- DELETE 
FROM url_excel_list_from_20231029
WHERE FILE_NAME IN (SELECT FILE_NAME  FROM load_vnc_org_lst_sim_20231029_dupli_url_org)

SELECT count(*)		-- DELETE 
FROM url_scrap_list_from_20231029
WHERE FILE_NAME IN (SELECT FILE_NAME  FROM load_vnc_org_lst_sim_20231029_dupli_url_org)

SELECT count(*)	-- 8408
-- SELECT count(DISTINCT FILE_NAME)	-- DELETE 
FROM url_scrap_txt_from_20231029
WHERE FILE_NAME IN (SELECT FILE_NAME  FROM load_vnc_org_lst_sim_20231029_dupli_url_org)



-- 마지막 확인
-- 1. 파일명 확인
SELECT *
FROM url_excel_list_from_20231029 
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1

SELECT *
FROM url_scrap_list_from_20231029 
GROUP BY FILE_NAME 
HAVING COUNT(FILE_NAME) > 1


-- 2. URL 확인
SELECT *
FROM url_excel_list_from_20231029 
GROUP BY DAT_SRC  
HAVING COUNT(DAT_SRC) > 1

SELECT *
FROM url_scrap_list_from_20231029 
GROUP BY DAT_SRC 
HAVING COUNT(DAT_SRC) > 1


