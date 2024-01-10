# URL 크롤링.. 크롤링된 xlsx 파일 업로드 코드

import pymysql
from pymysql import MySQLError
import os
import sys
import pandas as pd
from datetime import datetime

def count_word(text_column):
    total_word_count = 0
    for text in text_column:
        total_word_count += len(text.split())  # 공백을 기준으로 단어 분할
    return total_word_count

# 경로
root_path = f'Y:\\20231029/crawling/'    # 07

crawling_xlsx_list = os.listdir(root_path)
crawling_xlsx_list = [file for file in crawling_xlsx_list if not file.startswith('~$') and file != '.DS_Store' and file.endswith('.xlsx')]

for xlsx_name in crawling_xlsx_list:
    
    xlsx_path = os.path.join(root_path, xlsx_name)

    # 작업날짜, 작업자, 작업량 GET
    parts = xlsx_name.split('_')
    JOB_YMD_value = parts[0]
    WORKER_ID_value = parts[1]
    WORK_CNT_value = parts[2]
    print(f'{JOB_YMD_value}, {WORKER_ID_value}, {WORK_CNT_value}')

    SCRAP_FILE_NAME = os.path.basename(xlsx_path)

    # 파일 정보 가져오기
    #file_name, file_size, file_create_time, file_modi_time = get_file_info(xlsx_path)

    # 시간을 원하는 형식으로 변환
    #file_create_time = format_time(file_create_time)
    #file_modi_time = format_time(file_modi_time)

    #print(f'{file_create_time}, {file_modi_time}')

    # 테이블
    scrap_list_tb = 'url_scrap_list_from_20231029'   
    scrap_txt_tb = 'url_scrap_txt_from_20231029'

    # 엑셀에서 데이터 GET
    chunk_size = 300  # 원하는 청크 크기
    scrap_list_bulk_insert_data = []
    scrap_txt_bulk_insert_data = []

    # 단락 단위로 나누기 위한 문장 패턴
    read_data = False
    datas = []
    read_flag = False

    try:
        print(f"{xlsx_name} 읽기 시작")
        # print(f"{SCRAP_FILE_NAME} 읽기 시작")
        df = pd.read_excel(xlsx_path, engine='openpyxl')
        datas.append(df)

        for data in datas:
            for index, row in data.iterrows():
                
                # URL이 있다면 값을 가져옴
                if str(row.iloc[0]).startwith('http'):
                    read_flag = True
                    
                if read_flag:
                    SEQ = index + 1
                    DAT_SRC = str(row.iloc[0]).replace("'", "''")
                    TITLE = str(row.iloc[1]).replace("'", "''")
                    PUB_DATE = str(row.iloc[2]).strip()
                    DAT_TXT = str(row.iloc[3]).replace("'", "''")
                    WORD_CNT = count_word(str(row.iloc[3]))
                    # WORD_CNT = int(str(row.iloc[4]).strip())
                    
                    #print(f'{SEQ}번 {URL} -----')
                    #print(f'{URL_TITLE}, {URL_PUB_YMD}')
                    #print(f'{URL_TXT}')
                    #print(f'단어 개수 : {WORD_CNT}')
                    #print()
                    
                    scrap_list_bulk_insert_data.append((SCRAP_FILE_NAME,
                                                        WORKER_ID_value,
                                                        JOB_YMD_value,
                                                        SEQ,
                                                        DAT_SRC,
                                                        TITLE,
                                                        DAT_TXT,
                                                        PUB_DATE,
                                                        WORD_CNT))
                    
                    # txt 잘라서 url_scrap_txt_from_20230920에 넣기
                    # dat_txt = str(row[3]).replace("'", "''")
                    DAT_TXT = DAT_TXT.strip()                   # strip() : 앞뒤 공백 제거
                    DAT_TXT = DAT_TXT.replace("\u00A0", " ")    # strip()이 걸러내지 못하는 &nbsp 제거
                    DAT_TXT = DAT_TXT.replace("\uFEFF", " ")    # HTML 코드(&#65279;) 제거
                    DAT_TXT = DAT_TXT.replace('\t', ' ')
                    DAT_TXT = DAT_TXT.replace('\xa0', ' ')
                    # DAT_TXT = DAT_TXT.replace('\n', ' ')
                    # DAT_TXT = DAT_TXT.strip()
                    
                    # dat_txt = DAT_TXT.split('. ')
                    # dat_txt = DAT_TXT.split('  ')
                    dat_txt = DAT_TXT.split('\n')
                    dat_txt = [txts for txts in dat_txt if not txts == '' ]           # 빈공백으로만 있는 텍스트 제거
                    dat_txt = [txts for txts in dat_txt if not txts.strip() == '' ]   # 앞뒤 공백 자른 txts가 ''인 것 제거
                    # dat_txt = [txts for txts in dat_txt if not txts.strip() == 'Ảnh minh họa. Nguồn: MPI' ]   # txts가 'Ảnh minh họa. Nguồn: MPI'인 것 제거
                    # dat_txt = [txts for txts in dat_txt if not txts.strip() == 'Ảnh minh họa' ]   # txts가 'Ảnh minh họa'인 것 제거
                    
                    # 법률 문서의 경우
                    # dat_txt = dat_txt.split('\n\n\t')

                    if dat_txt:

                        # url_scrap_txt 테이블 컬럼 변수 초기화
                        scrap_dat_src = DAT_SRC
                        scrap_seq = 1
                        
                        for txt in dat_txt:       # 일반적인 경우
                        # for txt in dat_txt[:-1]:
                        # for txt in dat_txt[18:-4]:  # 05번의 경우(확인 필수)
                            # txt = txt + '. '
                            txt = txt.strip()   # 앞 뒤 공백 제거
                            
                            # print(f"{scrap_seq} : {txt} \n")
                            scrap_txt_bulk_insert_data.append((SCRAP_FILE_NAME,
                                                                scrap_dat_src,
                                                                TITLE,
                                                                scrap_seq,
                                                                txt))
                            scrap_seq += 1
                
        # read_data = False
        read_data = True
        print(f"{xlsx_name} 읽기 완료")
        
    except Exception as e:
        print(f'Data Read ERROR : {e} \n None of data inserted in DB.')
        sys.exit()

    # except 수행 안되었을 때
    else:
        # 300개씩 scrap_list_tb 테이블에 인서트
        if read_data:     
            # MySQL 연결 정보
            mysql_host = '172.30.1.36'
            mysql_port = 13333
            mysql_user = 'vnc'
            mysql_password = 'vnc'
            mysql_database = 'vncsim'
                
            try:
                connection = pymysql.connect(host=mysql_host,port=mysql_port,user=mysql_user,passwd=mysql_password,db=mysql_database)
                cursor = connection.cursor(pymysql.cursors.DictCursor)
                print("Connected to MySQL database \n")

                print(f'{scrap_list_tb} 테이블 인서트 시작')
                for i in range(0, len(scrap_list_bulk_insert_data), chunk_size):
                    batch = scrap_list_bulk_insert_data[i:i+chunk_size]
                    # print(batch)
                    
                    sql = ""
                    sql = sql + f" INSERT INTO {scrap_list_tb} "
                    sql = sql + " (SCRAP_FILE_NAME, WORKER_ID, JOB_YMD, SEQ, DAT_SRC, TITLE, DAT_TXT, PUB_DATE, WORD_CNT) "
                    sql = sql + " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
                    #print(f'{bulk_insert_datas}')
                    #print()
                    cursor.executemany(sql, batch)
                    connection.commit()
                    print(f'{len(batch)}개 저장완료')
                
                print(f'{scrap_txt_tb} 테이블 인서트 시작')
                for i in range(0, len(scrap_txt_bulk_insert_data), chunk_size):
                    batch = scrap_txt_bulk_insert_data[i:i+chunk_size]
                    # print(batch)
                    
                    sql = ""
                    sql = sql + f" INSERT INTO {scrap_txt_tb} "
                    sql = sql + " (FILE_NAME, DAT_SRC, TITLE, SEQ, DAT_TXT) "
                    sql = sql + " VALUES (%s, %s, %s, %s, %s)"
                    #print(f'{bulk_insert_datas}')
                    #print()
                    cursor.executemany(sql, batch)
                    connection.commit()
                    print(f'{len(batch)}개 저장완료')    
                
                print(f'{xlsx_name} 인서트 완료!')
            except MySQLError as e:
                print(f"DB Error: {e} \n {SCRAP_FILE_NAME} datas will be removed.")
                sql = ''
                sql = sql + f'DELETE FROM {scrap_list_tb} WHERE SCRAP_FILE_NAME LIKE "%{SCRAP_FILE_NAME}%"'
                cursor.execute(sql)
                connection.commit()
                sql = ''
                sql = sql + f'DELETE FROM {scrap_txt_tb} WHERE FILE_NAME LIKE "%{SCRAP_FILE_NAME}%"'
                cursor.execute(sql)
                connection.commit()
                sys.exit()
            finally:
                if connection:
                    connection.close()
                    print("Disconnected from MySQL database \n")
                    
                
            
            
            
            





