#!/usr/bin/env python
# coding: utf-8

# Импортируем библиотеки

# In[16]:


from sqlalchemy import create_engine
import pandas as pd
from datetime import datetime


# Настраиваем подключение к БД

# In[2]:


def connection_yandex_cloud_demo(echo):
    """Connection to DataBase demo"""
    login = 'student'
    password = 'student!'
    host = 'rc1b-7ng6ih3jte3824x8.mdb.yandexcloud.net'
    port = '6432'
    db_name = 'demo'
    return create_engine(f'postgresql://{login}:{password}@{host}:{port}/{db_name}', echo=echo)


# In[3]:


engine = connection_yandex_cloud_demo(echo=True)


# Формируем sql запрос

# In[7]:


sql = f'''
SELECT *
  FROM bookings.aircrafts_data
;
'''


# Запрашиваем данные из БД и сохраняем в Pandas DataFrame

# In[15]:


df = pd.read_sql(con=engine, sql=sql)


# Определяем текущую дату

# In[43]:


current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# Сохраняем данные в эксель

# In[44]:


df.to_excel(f'report_for_the_bo$$ {current_datetime}.xlsx')

