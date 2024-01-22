# URL 크롤링... 작업자 xlsx 파일 업로드

import sys

from docx import Document
import os
from datetime import datetime

import pandas as pd
import pymysql
from pymysql import MySQLError

def get_file_info(file_path):
    file_size = os.path.getsize(file_path)                  # 파일 크기를 바이트 단위로 가져오기 
    file_creation_time = os.path.getctime(file_path)        # 파일 생성일자를 가져오기
    file_modification_time = os.path.getmtime(file_path)    # 파일 최종 수정일자를 가져오기
    file_name = os.path.basename(file_path)                 # 파일명 추출
    
    return file_name, file_size, file_creation_time, file_modification_time

def count_words_docx(file_path):
    total_words = 0
    doc = docx.Document(file_path)

    for paragraph in doc.paragraphs:
        total_words += len(paragraph.text.split())   # 문서 내 단어 수 세기 

    return total_words

def format_time(timestamp):
    dt_object = datetime.fromtimestamp(timestamp)               # 에포크 시간을 datetime 객체로 변환
    formatted_time = dt_object.strftime('%Y-%m-%d %H:%M:%S')    # 원하는 형식으로 시간을 포맷팅
    
    return formatted_time

def lpad(i, width, fillchar='0'):
    # 입력된 숫자 또는 문자열 왼쪽에 fillchar 문자로 패딩
    return str(i).rjust(width, fillchar)

def check_prev_file(pre_job_ymd, pre_worker_id, pre_topic_cd, job_ymd, worker_id, topic_cd):
    if pre_job_ymd == job_ymd and pre_worker_id == worker_id and pre_topic_cd == topic_cd:
        return True
    
    
# MySQL 연결 정보
mysql_host = '172.30.1.36'
mysql_port = 13333
mysql_user = 'vnc'
mysql_password = 'vnc'
mysql_database = 'vncsim'
db = pymysql.connect(host=mysql_host,port=mysql_port,user=mysql_user,passwd=mysql_password,db=mysql_database)

try:
    cursor = db.cursor(pymysql.cursors.DictCursor)
    print("Connected to MySQL database \n\n")
    
    root_path = 'Y:/20230920/'
    
    excel_tb = 'url_excel_list_from_20230920'      
    
    ###################################################################################################################################3
    
    ## 주의!!!! ##
    # 특정 날짜에서 같은 작업자, 같은 주제분류를 가진 파일이 2개 이상 있을 시 + 테이블을 2개 이상으로 분리해서 인서트할 시,,!!
    # 첫 SEQ를 이전 테이블의 MAX(SEQ) 이후로 잡아야 나중에 load_vnc_org_lst_sim 테이블에 인서트 시 COL_PK 중복이 안걸린다!!!!!!!!!!!!!!!
    # 20231026_1 테이블 및 20231026_2 테이블의 03 코드 상황의 경우, 새로운 테이블의 SEQ 시작을 아예 2000, 또는 3000으로 잡아라!
    
    
    # 같은 날짜, 작업자, 주제코드인지 확인
    pre_worker_id = ''
    pre_job_ymd = ''
    pre_max_seq = ''
    pre_topic_cd =''
    same_woker_job_topic = False
    
    folder_list = os.listdir(root_path)
    #print('folder_list',folder_list)
    
    xlsx_files = [file for file in folder_list if file.endswith('.xlsx')] 
    # print(xlsx_files)
    for xlsx_file in xlsx_files:
        if not os.path.basename(xlsx_file).startswith('~$'):
            
            # xlsx_file 형식 : 20230911_CW045_1451_URL.xlsx
            parts = xlsx_file.split('_')
            first_value = parts[0]
            second_value = parts[1]
            third_value = parts[2]
            
            file_path = root_path+'/'+xlsx_file
            
            # 파일 정보 가져오기
            file_name, file_size, file_creation_time, file_modification_time = get_file_info(file_path)
            print(f"{file_name} 읽기 시작")

            # 시간을 원하는 형식으로 변환
            formatted_creation_time = format_time(file_creation_time)
            formatted_modification_time = format_time(file_modification_time)

            # 엑셀에서 데이터 GET
            datas = []
            bulk_insert_datas = []
            read_flag = False

            data_frame = pd.read_excel(file_path, engine='openpyxl')
            #data_frame = data_frame.dropna()
            datas.append(data_frame)
            
            chunk_size = 300  # 원하는 청크 크기
            
            # 같은 날짜, 작업자, 주제 분류파일 확인
            # topic_cd = str(data_frame.iloc[4, 16])
            topic_cd = '07' # 해당 날짜의 모든 파일이 '07'일 때를 위한 단순 처리
            # topic_cd = root_path[-3:-1]
            
            if check_prev_file(pre_job_ymd, pre_worker_id, pre_topic_cd, first_value, second_value, topic_cd):
                same_woker_job_topic = True
            else:
                same_woker_job_topic = False

            print(f"\t이전 파일의 작업일 : {pre_job_ymd}, 현재 읽는 파일의 작업일 : {first_value}")
            print(f"\t이전 파일의 작업자 : {pre_worker_id}, 현재 읽는 파일의 작업자 : {second_value}")
            print(f"\t이전 파일의 주제 분류 : {pre_topic_cd}, 현재 읽는 파일의 주제분류 : {topic_cd}")
            print(f"\tsame_woker_job_topic : {same_woker_job_topic}")
            print(f"\t이전 파일의 max seq : {pre_max_seq} \n")
                
            for df in datas:
                for index, row in df.iterrows():
                    # print('row',row)
                    # print('row[0]',row[0])
                    # print(str(row[0]))
                    if(str(row.iloc[0]) == '1'):
                        read_flag = True
                    
                    if(read_flag):
                        
                        # 같은 날짜의 테이블이 2개 이상이고 같은 작업자가 하나의 주제분류 코드로 2개 이상의 파일을 만든 경우를 위한 새로운 SEQ 설정 
                        # SEQ = 2000
                        
                        # 평상의 경우
                        # SEQ = 0
                        
                        COL_PK = ''
                        TOPIC_CD = '07'
                        # TOPIC_CD = root_path[-3:-1]
                        
                        if same_woker_job_topic:
                            # 동일한 작업자, 날짜, 주제분류의 경우
                            SEQ = int(pre_max_seq) + int(row.iloc[0])
                            # COL_PK = str(row.iloc[16]).split()[0] + '_' + second_value + '_' +  first_value + '_' + lpad(SEQ, 4, '0')    # 01_CW040_20230906_0001 형식
                            COL_PK = TOPIC_CD + '_' + second_value + '_' +  first_value + '_' + lpad(SEQ, 4, '0')    # 01_CW040_20230906_0001 형식
                            
                        else: 
                            
                            # 같은 날짜의 테이블이 2개 이상이고 같은 작업자가 하나의 주제분류 코드로 2개 이상의 파일을 만든 경우를 위한 새로운 SEQ 설정 
                            # new_index = 2000
                            # SEQ = int(row.iloc[0]) + new_index
                            
                            # 평상의 경우
                            SEQ = int(row.iloc[0])
                            
                            # COL_PK = str(row.iloc[16]).split()[0] + '_' + second_value + '_' +  first_value + '_' + lpad(int(row.iloc[0]), 4, '0')    # 01_CW040_20230906_0001 형식
                            # COL_PK = TOPIC_CD + '_' + second_value + '_' +  first_value + '_' + lpad(int(row.iloc[0]), 4, '0')    # 01_CW040_20230906_0001 형식
                            COL_PK = TOPIC_CD + '_' + second_value + '_' +  first_value + '_' + lpad(SEQ, 4, '0')                   # 01_CW040_20230906_0001 형식
                            
                        DAT_SRC = str(row.iloc[9]).replace("'", "''").strip()   # 작은따옴표를 두 번 사용하여 이스케이프
                        TITLE = str(row.iloc[13]).replace("'", "''").strip()  # 작은따옴표를 두 번 사용하여 이스케이프
                        FILE_NAME = COL_PK
                        DOC_STYLE = '구어체' if '구어체' in str(row.iloc[15]).strip() else '문어체'
                        # DOC_STYLE = '구어체'
                        # print(f"{COL_PK} - {SEQ} \n")
                        
                        # PUB_YMD가 다를 때(일반적인 경우)
                        bulk_insert_datas.append((COL_PK,
                                                SEQ,
                                                second_value,
                                                first_value,
                                                str(row.iloc[3]).strip(),
                                                str(row.iloc[4]).strip(),
                                                str(row.iloc[5]).strip(),
                                                str(row.iloc[6]).strip(),
                                                str(row.iloc[7]).strip(),
                                                str(row.iloc[8]).strip(),
                                                DAT_SRC,
                                                str(row.iloc[10]).strip(),
                                                # str(row.iloc[16]), 
                                                TOPIC_CD,
                                                str(row.iloc[11]).strip(),
                                                str(row.iloc[12]).strip(),
                                                TITLE,
                                                FILE_NAME, 
                                                DOC_STYLE))
                        
                        # 구어체의 경우(pub_date)가 오늘날짜인경우
                        # bulk_insert_datas.append((COL_PK,
                        #                         SEQ,
                        #                         second_value,
                        #                         first_value,
                        #                         first_value,
                        #                         str(row.iloc[4]),
                        #                         str(row.iloc[5]),
                        #                         str(row.iloc[6]),
                        #                         str(row.iloc[7]),
                        #                         str(row.iloc[8]),
                        #                         DAT_SRC,
                        #                         str(row.iloc[10]),
                        #                         TOPIC_CD,
                        #                         str(row.iloc[11]),
                        #                         str(row.iloc[12]),
                        #                         TITLE,
                        #                         FILE_NAME, 
                        #                         DOC_STYLE))
        
            # 300개씩 url_excel_list_user 테이블에 인서트
            for i in range(0, len(bulk_insert_datas), chunk_size):
                batch = bulk_insert_datas[i:i+chunk_size]
                # print(batch)
            
                sql = ""
                sql = sql + f" INSERT INTO {excel_tb} "
                sql = sql + " (col_pk, seq, worker_id, job_ymd, pub_ymd, wtr_kr, wtr_vn, ctr_kr, ctr_vn, org_typ, dat_src, dat_typ, topic_cd, topic_kr, topic_vn, title, file_name, doc_style) "
                sql = sql + " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                cursor.executemany(sql, batch)
                db.commit()
                print(f'\t{len(batch)}개 저장완료')
            print(f'{xlsx_file} 완료! \n')
            
            # 이전 파일 비교를 위해 현재 작업한 파일 저장 처리
            pre_job_ymd = first_value
            pre_worker_id = second_value
            pre_max_seq = SEQ
            pre_topic_cd = topic_cd

    print(f'{root_path} 처리 완료')
except MySQLError as e:
    print(f"Error: {e}")
    sql = ''
    sql = sql + f'DELETE FROM {excel_tb} WHERE WORKER_ID = {second_value} AND JOB_YMD = {first_value}'
    cursor.execute(sql)
    db.commit()
    sys.exit()

finally:
    db.close()
    print("Disconnected from MySQL database\n")
