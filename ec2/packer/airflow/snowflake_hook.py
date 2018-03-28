##########################################################################################
#  Project:      This module is a Snowflake Class Wrapper.
#  Orig Auth:    David Abercrombie, dabercrombie@sharethrough.com
#  Local Auth:   JMoney, 512-748-4704, jmoney@clarityinsights.com
#  Local Create: 2018-03-21
#  Notes:        2018-03-21 Modified the Abercrombie code to allow bulk copy and
#                querying without having to use pandas
#  Mods:      1)
#  TODO:      1) Modify to use __init__ that allows a lot more work to be done in
#                the connection rather than establishing a connection for every query.
#                Will use db_wrapper to accomplish this
##########################################################################################


import snowflake.connector
from airflow.hooks.dbapi_hook import DbApiHook
import pandas as pd
import logging

class SnowflakeHook(DbApiHook):
    conn_name_attr = 'snowflake_conn_id'
    default_conn_name = 'snowflake_default'
    supports_autocommit = True

    def get_conn(self, conn_name=default_conn_name):
        logging.info('Connecting to Snowflake using conn_name = ' + conn_name)
        conn = self.get_connection(conn_name)
        conn = snowflake.connector.connect(
            account=conn.host,
            user=conn.login,
            password=conn.password,
            schema=conn.schema,
            database=conn.extra_dejson.get('database'),
            warehouse=conn.extra_dejson.get('warehouse'),
            role=conn.extra_dejson.get('role'),
            region=conn.extra_dejson.get('region'),
            autocommit=conn.extra_dejson.get('autocommit'),
        )
        conn.conn_name = conn_name
        return conn

    def get_pandas_df(self, sql):
        conn = self.get_conn(self.snowflake_conn_id)
        df = pd.read_sql_query(sql, conn)
        return df

    def get_records(self, sql):
        """Have not tested yet, but based on get_pandas_df testing, we need to pass connection param to get_conn()"""
        conn = self.get_conn(self.snowflake_conn_id)
        result=conn.execute(sql)
        results=result.fetchall()
        return results

    def query(self,q,params=None):
        """From jmoney's db_wrapper allows return of a full list of rows(tuples)"""
        conn = self.get_conn(self.snowflake_conn_id)
        self.cur = conn.cursor()
        if params == None: #no Params, so no insertion
            self.cur.execute(q)
        else: #make the parameter substitution
            self.cur.execute(q,params)
        self.results = self.cur.fetchall()
        self.rowcount = self.cur.rowcount
        self.columnnames = [colspec[0] for colspec in self.cur.description]
        return self.results

    def load_files(self,fpat_in,tn_in,delimiter=','):
        """
        This loads files from the filesystem to the snowflake db
        fpat_in is expected to be the full path and filename pattern(incl wildcards) to be loaded
         e.g. fpat_in = c:\downloads\mytable_*.gz
        tn_in is expected to be the table_name to be loaded. May include schema(?)
        """
        conn = self.get_conn(self.snowflake_conn_id)
        self.cur = conn.cursor()
        p = 'put file://{0} @%{1};'.format(fpat_in,tn_in)
        #c = "copy into {0} file_format = (type csv field_delimiter = '{1}');".format(tn_in,delimiter)
        c = "copy into {0};".format(tn_in)
        logging.info('Using conn_name = {0} to Execute cmd = {1}'.format(conn.conn_name,p))
        self.cur.execute(p)
        logging.info('Using conn_name = {0} to Execute cmd = {1}'.format(conn.conn_name,c))
        self.cur.execute(c)
