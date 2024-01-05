USE vncsim;

-- 0. 전체 확인
SELECT trim(substring_index(DAT_SRC, '/', 3)), WTR_KR , WTR_VN , CTR_KR , CTR_VN , ORG_TYP , DAT_TYP , TOPIC_KR , TOPIC_VN 
FROM url_excel_list_from_20231029
GROUP BY TOPIC_CD , WORKER_ID , JOB_YMD , trim(substring_index(DAT_SRC, '/', 3)), WTR_KR, WTR_VN, CTR_KR , CTR_VN , DAT_TYP , TOPIC_KR , TOPIC_VN, ORG_TYP


-- 1. TOPIC_KR, TOPIC_VN 설정
SELECT DISTINCT TOPIC_KR, TOPIC_VN, LEFT(FILE_NAME, 2)  
FROM url_excel_list_from_20231029;
-- TOPIC_KR			TOPIC_VN								LEFT(FILE_NAME, 2)
-- 산업분야/경제		XA HOI/ CHINH TRI/ THONG TIN CHUNG		06
-- 산업분야/경제   		LĨNH VỰC CÔNG NGHIỆP/ KINH TẾ 			02
-- IT/과학			IT/ KHOA HỌC							02
-- 지리/자연/국가		ĐỊA LÝ/THIÊN NHIÊN/QUỐC GIA				03
-- 지리/자연/국가		ĐỊA LÍ/ TỰ NHIÊN/QUỐC GIA				03
-- 산업분야/경제   		LĨNH VỰC CÔNG NGHIỆP/ KINH TẾ 			06

SELECT *
FROM url_excel_list_from_20231029
WHERE TOPIC_KR = '산업분야/경제'

SELECT DISTINCT LEFT(FILE_NAME, 2)  
FROM url_excel_list_from_20231029;
-- 03

UPDATE vnc.load_vnc_org_lst_sim
SET TOPIC_KR = '사회/정치/일반', TOPIC_VN = 'Xã hội/Chính trị/Tổng hợp'
WHERE LEFT(FILE_NAME, 2) = '01';
-- 

UPDATE vncsim.url_excel_list_from_20231029
SET TOPIC_KR = 'IT/과학', TOPIC_VN = 'CNTT/Khoa học'
WHERE LEFT(FILE_NAME, 2) = '02';

UPDATE url_excel_list_from_20231029
SET TOPIC_KR = '지리/자연/국가', TOPIC_VN = 'Địa lý/Thiên nhiên/Quốc gia'
WHERE LEFT(FILE_NAME, 2) = '03';
-- 

UPDATE vnc.load_vnc_org_lst_sim
SET TOPIC_KR = '건강/의학', TOPIC_VN = 'Sức khỏe/Y học'
WHERE LEFT(FILE_NAME, 2) = '04';

UPDATE url_excel_list_from_20231029
SET TOPIC_KR = '문화/역사/예술', TOPIC_VN = 'Văn hóa/Lịch sử/Nghệ thuật'
WHERE LEFT(FILE_NAME, 2) = '05';
-- 

UPDATE url_excel_list_from_20231029
SET TOPIC_KR = '경제/산업분야', TOPIC_VN = 'Kinh tế/Lĩnh vực công nghiệp'
WHERE LEFT(FILE_NAME, 2) = '06';
-- 

UPDATE vnc.load_vnc_org_lst_sim
SET TOPIC_KR = '관광/생활정보/스포츠', TOPIC_VN = 'Du lịch/Thông tin cuộc sống/Thể thao'
WHERE LEFT(FILE_NAME, 2) = '07';
-- 13099


-- https:// 정제
SELECT *
-- SELECT count(*)
FROM url_excel_list_from_20231029
WHERE DAT_SRC NOT LIKE 'http%'


-- 2. WTR_KR, WTR_VN, CTR_KR , CTR_VN 설정
SELECT trim(substring_index(DAT_SRC, '/', 3)) "url", WTR_KR, WTR_VN, CTR_KR , CTR_VN , DAT_TYP , TOPIC_KR , TOPIC_VN 
FROM url_excel_list_from_20231029 uelf 
GROUP BY substring_index(DAT_SRC, '/', 3), WTR_KR ;
-- url								WTR_KR				WTR_VN					CTR_KR			CTR_VN				
-- http://dosm.gov.vn
-- https://baotintuc.vn
-- https://tapchicongthuong.vn
-- https://thethaovietnamplus.vn
-- https://vietnamnet.vn
-- https://www.mard.gov.vn


SELECT trim(substring_index(DAT_SRC, '/', 3)) "url", WTR_KR, WTR_VN, CTR_KR , CTR_VN , DAT_TYP , TOPIC_KR , TOPIC_VN 
FROM url_excel_list_from_20231029 uelf 
GROUP BY substring_index(DAT_SRC, '/', 3), DAT_TYP

UPDATE url_excel_list_from_20231029
SET WTR_KR = '베트남 측정, 지도 및 지리 정보부 - 자원환경부', 
	WTR_VN = 'CỤC ĐO ĐẠC, BẢN ĐỒ VÀ THÔNG TIN ĐỊA LÝ VIỆT NAM - BỘ TÀI NGUYÊN VÀ MÔI TRƯỜNG',
	CTR_KR = '베트남 측정, 지도 및 지리 정보부 - 자원환경부',
	CTR_VN = 'CỤC ĐO ĐẠC, BẢN ĐỒ VÀ THÔNG TIN ĐỊA LÝ VIỆT NAM - BỘ TÀI NGUYÊN VÀ MÔI TRƯỜNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'http://dosm.gov.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '베트남통신사', 
	WTR_VN = 'TIN TỨC',
	CTR_KR = '베트남통신사',
	CTR_VN = 'TIN TỨC'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://baotintuc.vn';
-- 15787

UPDATE url_excel_list_from_20231029
SET WTR_KR = '베트남통신사', 
	WTR_VN = 'TIN TỨC',
	CTR_KR = '베트남통신사',
	CTR_VN = 'TIN TỨC'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = '﻿https://baotintuc.vn';
-- 1191

UPDATE load_vnc_org_lst_sim_301_2
SET WTR_KR = '마이아잉', 
	WTR_VN = 'MAI ANH',
	CTR_KR = '마이아잉',
	CTR_VN = 'MAI ANH'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtedothi.vn';
-- 477

UPDATE url_excel_list_from_20231029
SET WTR_KR = '중앙경제위원회', 
	WTR_VN = 'BAN KINH TẾ TRUNG ƯƠNG',
	CTR_KR = '중앙경제위원회',
	CTR_VN = 'BAN KINH TẾ TRUNG ƯƠNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'http://kinhtetrunguong.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '중앙경제위원회', 
	WTR_VN = 'BAN KINH TẾ TRUNG ƯƠNG',
	CTR_KR = '중앙경제위원회',
	CTR_VN = 'BAN KINH TẾ TRUNG ƯƠNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtetrunguong.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '환경경제', 
	WTR_VN = 'KINH TẾ MÔI TRƯỜNG',
	CTR_KR = '환경경제',
	CTR_VN = 'KINH TẾ MÔI TRƯỜNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://kinhtemoitruong.vn';


UPDATE url_excel_list_from_20231029
SET WTR_KR = '베트남라오스', 
	WTR_VN = 'VIỆT LÀO',
	CTR_KR = '베트남라오스',
	CTR_VN = 'VIỆT LÀO'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'http://vietlao.vietnam.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '문학을 잘함', 
	WTR_VN = 'GIỎI VĂN',
	CTR_KR = '문학을 잘함',
	CTR_VN = 'GIỎI VĂN'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'http://www.gioivan.net';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '법률 문서', 
	WTR_VN = 'VĂN BẢN PHÁP QUY',
	CTR_KR = '법률 문서',
	CTR_VN = 'VĂN BẢN PHÁP QUY'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://bientap.vbpl.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '문화체육관광부', 
	WTR_VN = 'BỘ VĂN HÓA, THỂ THAO VÀ DU LỊCH',
	CTR_KR = '문화체육관광부',
	CTR_VN = 'BỘ VĂN HÓA, THỂ THAO VÀ DU LỊCH'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://bvhttdl.gov.vn';

UPDATE vnc.load_vnc_org_lst_sim 
SET WTR_KR = '베트남 동화', 
	WTR_VN = 'TRUYỆN CỔ TÍCH ',
	CTR_KR = '베트남 동화',
	CTR_VN = 'TRUYỆN CỔ TÍCH '
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://cotich.net';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '요안냔째신문', 
	WTR_VN = 'DOANH NHÂN TRẺ VIỆT NAM',
	CTR_KR = '요안냔째신문',
	CTR_VN = 'DOANH NHÂN TRẺ VIỆT NAM'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://doanhnhantrevietnam.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '보건부', 
	WTR_VN = 'BỘ Y TẾ',
	CTR_KR = '보건부',
	CTR_VN = 'BỘ Y TẾ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://moh.gov.vn';
-- 188

UPDATE url_excel_list_from_20230925
SET WTR_KR = '산업통상부', 
	WTR_VN = 'BỘ CÔNG THƯƠNG',
	CTR_KR = '산업통상부',
	CTR_VN = 'BỘ CÔNG THƯƠNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://moit.gov.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '역사 연구', 
	WTR_VN = 'NGHIÊN CỨU LỊCH SỬ',
	CTR_KR = '역사 연구',
	CTR_VN = 'NGHIÊN CỨU LỊCH SỬ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://nghiencuulichsu.com';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '상공업신문', 
	WTR_VN = 'BÁO CÔNG THƯƠNG',
	CTR_KR = '상공업신문',
	CTR_VN = 'BÁO CÔNG THƯƠNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://tapchicongthuong.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '꽁트엉 산업 및 무역 잡지', 
	WTR_VN = 'TẠP CHÍ CÔNG THƯƠNG',
	CTR_KR = '꽁트엉 산업 및 무역 잡지',
	CTR_VN = 'TẠP CHÍ CÔNG THƯƠNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://tapchicongthuong.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '베트남 동화', 
	WTR_VN = 'TRUYỆN CỔ TÍCH',
	CTR_KR = '베트남 동화',
	CTR_VN = 'TRUYỆN CỔ TÍCH'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyencotich.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '베트남 뚜오이째 신문사', 
	WTR_VN = 'TUỔI TRẺ',
	CTR_KR = '베트남 뚜오이째 신문사',
	CTR_VN = 'TUỔI TRẺ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://tuoitre.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '농업 및 농촌 개발부', 
	WTR_VN = 'BỘ NÔNG NGHIỆP VÀ PHÁT TRIỂN NÔNG THÔN',
	CTR_KR = '농업 및 농촌 개발부',
	CTR_VN = 'BỘ NÔNG NGHIỆP VÀ PHÁT TRIỂN NÔNG THÔN'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mard.gov.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '보건부', 
	WTR_VN = 'BỘ Y TẾ',
	CTR_KR = '보건부',
	CTR_VN = 'BỘ Y TẾ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.moh.gov.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '과학기술부', 
	WTR_VN = 'BỘ KHOA HỌC VÀ CÔNG NGHỆ',
	CTR_KR = '과학기술부',
	CTR_VN = 'BỘ KHOA HỌC VÀ CÔNG NGHỆ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.most.gov.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '계획투자부', 
	WTR_VN = 'BỘ KẾ HOẠCH VÀ ĐẦU TƯ',
	CTR_KR = '계획투자부',
	CTR_VN = 'BỘ KẾ HOẠCH VÀ ĐẦU TƯ'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://www.mpi.gov.vn';

UPDATE url_excel_list_from_20230925
SET WTR_KR = '건강 및 생활 신문', 
	WTR_VN = 'SỨC KHỎE &  ĐỜI SỐNG',
	CTR_KR = '건강 및 생활 신문',
	CTR_VN = 'SỨC KHỎE &  ĐỜI SỐNG'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://suckhoedoisong.vn';

UPDATE url_excel_list_from_20231029
SET WTR_KR = '베트남넷 신문', 
	WTR_VN = 'Báo Vietnamnet',
	CTR_KR = '베트남넷 신문',
	CTR_VN = 'Báo Vietnamnet'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamnet.vn';
-- 4373

UPDATE url_excel_list_from_20230925
SET WTR_KR = '체육국', 
	WTR_VN = 'CỤC THỂ DỤC THỂ THAO',
	CTR_KR = '체육국',
	CTR_VN = 'CỤC THỂ DỤC THỂ THAO'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://tdtt.gov.vn';
-- 1860

UPDATE url_excel_list_from_20230925
SET WTR_KR = '베트남 관광청 신문', 
	WTR_VN = 'BÁO TỔNG CỤC DU LỊCH VIỆT NAM',
	CTR_KR = '베트남 관광청 신문',
	CTR_VN = 'BÁO TỔNG CỤC DU LỊCH VIỆT NAM'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://vietnamtourism.gov.vn';
-- 620

UPDATE url_excel_list_from_20230925
SET WTR_KR = '스포츠 및 문화', 
	WTR_VN = 'THỂ THAO & VĂN HÓA',
	CTR_KR = '스포츠 및 문화',
	CTR_VN = 'THỂ THAO & VĂN HÓA'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovanhoa.vn';

UPDATE url_excel_list_from_20231012
SET WTR_KR = '소설좋아함.Vn', 
	WTR_VN = 'ThichTruyen.Vn',
	CTR_KR = '소설좋아함.Vn',
	CTR_VN = 'ThichTruyen.Vn'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://iztruyen.com';
-- 53

UPDATE url_excel_list_from_20231013_2
SET WTR_KR = '소설좋아함.Vn', 
	WTR_VN = 'ThichTruyen.Vn',
	CTR_KR = '소설좋아함.Vn',
	CTR_VN = 'ThichTruyen.Vn'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://thichtruyen.vn';

UPDATE url_excel_list_from_20231016_2
SET WTR_KR = '도서관.Vn', 
	WTR_VN = 'truyen.tangthuvien.Vn',
	CTR_KR = '도서관.Vn',
	CTR_VN = 'truyen.tangthuvien.Vn'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://truyen.tangthuvien.vn';

UPDATE url_excel_list_from_20231018_07
SET WTR_KR = '베트남 스포츠 플러스', 
	WTR_VN = 'THỂ THAO VIỆT NAM PLUS',
	CTR_KR = '스포츠정보통신센터',
	CTR_VN = 'TRUNG TÂM THÔNG TIN - TRUYỀN THÔNG THỂ DỤC THỂ THAO'
WHERE trim(substring_index(DAT_SRC, '/', 3)) = 'https://thethaovietnamplus.vn';
-- 208






-- 3. max 작업날짜 확인
SELECT max(JOB_YMD), max(WORKER_ID), min(JOB_YMD), min(WORKER_ID)
FROM url_excel_list_from_20231029
-- 20231016	CW003	20231016	CW001

SELECT max(JOB_YMD), max(WORKER_ID), min(JOB_YMD), min(WORKER_ID)
FROM url_scrap_list_from_20231029
-- 20231016	CW003	20231016	CW001




-- 4. PUB_YMD 확인
SELECT length(PUB_YMD)
FROM url_excel_list_from_20231029 uelf 
GROUP BY length(PUB_YMD)

SELECT *
FROM url_excel_list_from_20231029
WHERE LENGTH(PUB_YMD) = 3;


SELECT PUB_YMD
FROM url_excel_list_from_20231029
GROUP BY PUB_YMD;
-- 20231016


-- 날짜형식 아닌 것 확인
SELECT *
FROM url_excel_list_from_20231029
WHERE PUB_YMD NOT REGEXP '^(1[0-9]|2[0-3])(\\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\\d{1}|3[01])' 

SELECT *
FROM url_excel_list_from_20231029
WHERE (mid(PUB_YMD, 5, 2) NOT IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
OR right(PUB_YMD, 2) > 31
OR right(PUB_YMD, 2) = '00')
-- 0

SELECT left(PUB_YMD, 4) "년도별", mid(PUB_YMD, 5, 2) "월별", min(right(PUB_YMD, 2)) "최소일", max(RIGHT(PUB_YMD, 2)) "최대일"
FROM url_excel_list_from_20231029 uelf 
GROUP BY left(PUB_YMD, 4), mid(PUB_YMD, 5, 2)
-- 년도별		월별		최소일	최대일
-- 2023		10		04		12


-- 짝수 달의 최대 일이 31인 행
SELECT *
FROM url_excel_list_from_20231029 uelf 
GROUP BY left(PUB_YMD, 4), mid(PUB_YMD, 5, 2)
HAVING max(RIGHT(PUB_YMD, 2)) = '31'
AND mid(PUB_YMD, 5, 2) NOT IN ('01', '03', '05', '07', '08', '10', '12')

-- 2월의 최대 날자 확인
SELECT left(PUB_YMD, 4) "년도별", mid(PUB_YMD, 5, 2) "월별", min(right(PUB_YMD, 2)) "최소일", max(RIGHT(PUB_YMD, 2)) "최대일"
FROM url_excel_list_from_20231029 uelf
WHERE mid(PUB_YMD, 5, 2) = '02'
GROUP BY left(PUB_YMD, 4), mid(PUB_YMD, 5, 2)
-- 20140230


-- 5. url 확인
SELECT *
FROM url_excel_list_from_20231029
WHERE DAT_SRC NOT LIKE 'http%'
-- NONE

SELECT *
FROM url_scrap_list_from_20231029
WHERE DAT_SRC NOT LIKE 'http%'
-- NONE

SELECT *
FROM url_scrap_txt_from_20231029
WHERE DAT_SRC NOT LIKE 'http%'
-- NONE




-- 6. 모든 값이 들어있는지 확인
SELECT *
FROM url_excel_list_from_20231029
WHERE (WORKER_ID IS NULL 
OR JOB_YMD IS NULL 
OR PUB_YMD IS NULL 
OR WTR_KR IS NULL 
OR WTR_VN IS NULL 
OR CTR_KR IS NULL 
OR CTR_VN IS NULL 
OR ORG_TYP IS NULL 
OR DAT_SRC IS NULL 
OR DAT_TYP IS NULL 
OR TOPIC_CD IS NULL 
OR TOPIC_KR IS NULL 
OR TOPIC_VN IS NULL 
OR TITLE IS NULL 
OR DOC_STYLE IS NULL
OR WORKER_ID = 'nan'
OR JOB_YMD = 'nan'
OR PUB_YMD = 'nan'
OR WTR_KR = 'nan'
OR WTR_VN = 'nan'
OR CTR_KR = 'nan'
OR CTR_VN = 'nan'
OR ORG_TYP = 'nan'
OR DAT_SRC = 'nan'
OR DAT_TYP = 'nan'
OR TOPIC_CD = 'nan' 
OR TOPIC_KR = 'nan'
OR TOPIC_VN = 'nan'
OR TITLE = 'nan'
OR DOC_STYLE = 'nan');
-- GROUP BY WORKER_ID, JOB_YMD 

SELECT *
FROM url_excel_list_from_20231029	-- UPDATE url_excel_list_from_20231029 SET org_typ = 'html'
WHERE ORG_TYP = 'nan'


-- UPDATE url_excel_list_from_20231029 a
JOIN url_scrap_list_from_20231029 b
ON a.FILE_NAME = b.FILE_NAME 
SET a.TITLE = b.TITLE 
-- WHERE a.TITLE = 'nan'
-- 1259


SELECT *	-- SELECT count(*)	-- DELETE 
FROM url_scrap_list_from_20231029
WHERE FILE_NAME IS NULL 
OR SCRAP_FILE_NAME IS NULL 
OR TITLE IS NULL 
OR DAT_TXT IS NULL 
OR TITLE = 'nan'
OR WORD_CNT = 0
OR DAT_TXT = 'nan'
-- 07_CW046_20231023_1648	https://vietnamnet.vn/chi-hon-34-trieu-de-cat-mi-lam-dep-cho-meo-V79600.html
-- 07_CW046_20231023_2016	https://vietnamnet.vn/ca-bi-hap-chin-van-nhay-vot-khoi-dia-khien-khach-hoang-so-V72829.html

SELECT *
FROM url_scrap_txt_from_20231018_07
WHERE FILE_NAME = '07_CW046_20231023_2016'


SELECT *
FROM url_scrap_txt_from_20231029
WHERE FILE_NAME IS NULL 
OR seq = NULL 
OR DAT_TXT IS NULL 
OR DAT_TXT = 'nan'
-- NONE


