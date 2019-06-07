

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import pandas_profiling as pp
from sklearn.cluster import KMeans
```

    C:\Users\charl\Anaconda3\lib\site-packages\pandas_profiling\plot.py:15: UserWarning: 
    This call to matplotlib.use() has no effect because the backend has already
    been chosen; matplotlib.use() must be called *before* pylab, matplotlib.pyplot,
    or matplotlib.backends is imported for the first time.
    
    The backend was *originally* set to 'module://ipykernel.pylab.backend_inline' by the following code:
      File "C:\Users\charl\Anaconda3\lib\runpy.py", line 193, in _run_module_as_main
        "__main__", mod_spec)
      File "C:\Users\charl\Anaconda3\lib\runpy.py", line 85, in _run_code
        exec(code, run_globals)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel_launcher.py", line 16, in <module>
        app.launch_new_instance()
      File "C:\Users\charl\Anaconda3\lib\site-packages\traitlets\config\application.py", line 658, in launch_instance
        app.start()
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\kernelapp.py", line 486, in start
        self.io_loop.start()
      File "C:\Users\charl\Anaconda3\lib\site-packages\tornado\platform\asyncio.py", line 132, in start
        self.asyncio_loop.run_forever()
      File "C:\Users\charl\Anaconda3\lib\asyncio\base_events.py", line 421, in run_forever
        self._run_once()
      File "C:\Users\charl\Anaconda3\lib\asyncio\base_events.py", line 1425, in _run_once
        handle._run()
      File "C:\Users\charl\Anaconda3\lib\asyncio\events.py", line 127, in _run
        self._callback(*self._args)
      File "C:\Users\charl\Anaconda3\lib\site-packages\tornado\platform\asyncio.py", line 122, in _handle_events
        handler_func(fileobj, events)
      File "C:\Users\charl\Anaconda3\lib\site-packages\tornado\stack_context.py", line 300, in null_wrapper
        return fn(*args, **kwargs)
      File "C:\Users\charl\Anaconda3\lib\site-packages\zmq\eventloop\zmqstream.py", line 450, in _handle_events
        self._handle_recv()
      File "C:\Users\charl\Anaconda3\lib\site-packages\zmq\eventloop\zmqstream.py", line 480, in _handle_recv
        self._run_callback(callback, msg)
      File "C:\Users\charl\Anaconda3\lib\site-packages\zmq\eventloop\zmqstream.py", line 432, in _run_callback
        callback(*args, **kwargs)
      File "C:\Users\charl\Anaconda3\lib\site-packages\tornado\stack_context.py", line 300, in null_wrapper
        return fn(*args, **kwargs)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\kernelbase.py", line 283, in dispatcher
        return self.dispatch_shell(stream, msg)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\kernelbase.py", line 233, in dispatch_shell
        handler(stream, idents, msg)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\kernelbase.py", line 399, in execute_request
        user_expressions, allow_stdin)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\ipkernel.py", line 208, in do_execute
        res = shell.run_cell(code, store_history=store_history, silent=silent)
      File "C:\Users\charl\Anaconda3\lib\site-packages\ipykernel\zmqshell.py", line 537, in run_cell
        return super(ZMQInteractiveShell, self).run_cell(*args, **kwargs)
      File "C:\Users\charl\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py", line 2662, in run_cell
        raw_cell, store_history, silent, shell_futures)
      File "C:\Users\charl\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py", line 2785, in _run_cell
        interactivity=interactivity, compiler=compiler, result=result)
      File "C:\Users\charl\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py", line 2901, in run_ast_nodes
        if self.run_code(code, result):
      File "C:\Users\charl\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py", line 2961, in run_code
        exec(code_obj, self.user_global_ns, self.user_ns)
      File "<ipython-input-1-4baf6db70926>", line 3, in <module>
        import matplotlib.pyplot as plt
      File "C:\Users\charl\Anaconda3\lib\site-packages\matplotlib\pyplot.py", line 71, in <module>
        from matplotlib.backends import pylab_setup
      File "C:\Users\charl\Anaconda3\lib\site-packages\matplotlib\backends\__init__.py", line 16, in <module>
        line for line in traceback.format_stack()
    
    
      matplotlib.use(BACKEND)
    

## Import data from College Scorecard and College Chronicle


```python
cc_details = pd.read_csv('cc_institution_details.csv',encoding='cp1252')
data = pd.read_csv('Most-Recent-Cohorts-All-Data-Elements.csv')
```

    C:\Users\charl\Anaconda3\lib\site-packages\IPython\core\interactiveshell.py:2785: DtypeWarning: Columns (6,9,987,988,989,990,991,992,993,994,995,996,997,998,999,1000,1001,1002,1003,1004,1005,1006,1008,1009,1010,1011,1014,1015,1016,1017,1018,1019,1021,1022,1023,1027,1028,1029,1030,1031,1032,1034,1035,1036,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1065,1066,1067,1068,1069,1070,1071,1073,1074,1075,1076,1078,1079,1080,1081,1082,1083,1084,1086,1087,1088,1089,1091,1092,1093,1094,1095,1096,1097,1099,1100,1101,1102,1104,1105,1106,1107,1108,1109,1110,1112,1113,1114,1115,1118,1119,1121,1122,1123,1125,1127,1128,1131,1132,1134,1135,1136,1138,1140,1141,1144,1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1157,1158,1159,1160,1161,1162,1163,1164,1165,1166,1167,1170,1171,1172,1173,1174,1175,1177,1178,1179,1180,1183,1184,1185,1186,1187,1188,1190,1192,1196,1199,1200,1201,1209,1212,1213,1214,1222,1223,1224,1225,1226,1227,1235,1236,1237,1238,1239,1240,1248,1249,1250,1251,1252,1253,1257,1261,1262,1263,1264,1265,1266,1270,1274,1275,1276,1277,1278,1279,1281,1283,1287,1288,1289,1290,1291,1292,1294,1296,1303,1309,1316,1322,1326,1327,1328,1329,1330,1331,1333,1335,1339,1340,1341,1342,1343,1344,1346,1348,1379,1380,1381,1382,1383,1384,1385,1386,1387,1388,1389,1390,1391,1392,1393,1394,1395,1396,1397,1398,1399,1400,1401,1402,1403,1404,1405,1406,1407,1408,1431,1432,1433,1475,1476,1477,1478,1479,1480,1481,1482,1483,1484,1485,1486,1487,1488,1489,1490,1491,1492,1493,1494,1495,1496,1497,1498,1499,1500,1501,1502,1503,1504,1517,1518,1519,1529,1530,1531,1532,1534,1535,1537,1538,1539,1540,1542,1575,1576,1577,1578,1579,1580,1581,1582,1583,1584,1585,1586,1587,1588,1589,1590,1591,1592,1593,1594,1595,1596,1597,1598,1599,1600,1601,1602,1606,1608,1610,1611,1614,1615,1616,1619,1620,1621,1622,1623,1624,1625,1626,1627,1628,1629,1636,1637,1638,1639,1640,1641,1642,1643,1644,1645,1646,1647,1648,1649,1650,1651,1652,1653,1654,1655,1656,1657,1658,1659,1660,1661,1662,1663,1664,1665,1666,1667,1668,1669,1670,1671,1672,1673,1674,1675,1676,1677,1678,1679,1680,1681,1682,1683,1684,1685,1686,1687,1688,1689,1690,1691,1692,1693,1694,1695,1696,1697,1698,1699,1700,1701,1702,1703,1704,1705,1706,1707,1708,1725,1726,1727,1728,1729,1743,1815,1816,1817,1818,1823,1824,1830,1831,1844,1845,1846,1879,1880,1881,1882,1883,1884,1885,1886,1887,1888,1889,1890,1891,1892,1893,1894,1895,1896,1897,1898) have mixed types. Specify dtype option on import or set low_memory=False.
      interactivity=interactivity, compiler=compiler, result=result)
    


```python
# Notes
# Descriptive columns:
# unitid: school identifier --> use to join back for info
# city: descriptive info
# state --> use to filter cluster
# hbcu --> use to filter cluster (ethnicity)
# site: website --> potentially use in dashboard for quick information access
# long_x --> longitude
# lat_y  --> latitidude

# College Completion Details Relevant survey columns:
# unitid --> use to join back for info
# basic --> Program offerings/strengths, Charles identified to filter the types of schools based on program interests
# student_count --> use for size and calculation of faculty-student ratios, to be used in cluster
# awards_per_value --> use for ranking in cluster
# aid_value --> average aid per undergrad student, filter if not possible to cluster
# aid_percentile --> potential replacement for value, based on input assign bucketed values financial aid 1-5 importance
# endow_value/percentile --> donations to school for academic use, based on input assign bucketed values academic funding 1-5 importance
# grad_100/150_value/percentile --> graduation rates for 100/150% of program time, use for ranking in cluster
# pell_value/percentile --> percent students receiving pell grants, based on input assign bucketed values financial aid 1-5 importance
# retain_value/percentile --> freshman retention
# ft_fac_value --> % FT treaching faculty, non med school
# counted_pct --> first time, degree seeking, FTE students that would be tracked

# Data columns:
# unitid --> join
# CCUGPROF --> carnegie classification for undergrads
# HBCU - hbcu flag
# MENONLY - men only
# WOMENONLY - women only
# TUITFTE - net tuition per FTE student
# INEXPFTE - instructional expenditures per FTE student
# PFTEFAC - FT faculty, check against ft_fac
# AGE_ENTRY - average age of entry
# FEMALE - proportion, use to get male proportion
# UGDS_MEN - share men
# UGDS_WOMEN - share women

# bad columns:
# med_sat_value
# med_sat_percentile
# all VSA

```


```python
cc_details.basic.unique()
```




    array(['Masters Colleges and Universities--larger programs',
           'Research Universities--very high research activity',
           'Baccalaureate Colleges--Arts & Sciences',
           'Research Universities--high research activity',
           'Associates--Public Rural-serving Medium',
           'Baccalaureate Colleges--Diverse Fields',
           'Baccalaureate/Associates Colleges',
           'Associates--Public Suburban-serving Multicampus',
           'Associates--Public Rural-serving Large',
           'Associates--Public Rural-serving Small',
           'Associates--Public Urban-serving Multicampus',
           'Masters Colleges and Universities--medium programs',
           'Associates--Private For-profit',
           'Theological seminaries- Bible colleges- and other faith-related institutions',
           'Masters Colleges and Universities--smaller programs',
           'Associates--Private For-profit 4-year Primarily Associates',
           'Not applicable- not in Carnegie universe',
           'Schools of art- music- and design',
           'Other technology-related schools', 'Tribal Colleges',
           'Associates--Public Urban-serving Single Campus',
           'Doctoral/Research Universities',
           'Associates--Public 2-year colleges under 4-year universities',
           'Associates--Private Not-for-profit 4-year Primarily Associates',
           'Associates--Public Suburban-serving Single Campus',
           'Associates--Private Not-for-profit',
           'Other health professions schools',
           'Schools of business and management',
           'Associates--Public 4-year Primarily Associates',
           'Associates--Public Special Use', 'Schools of engineering',
           'Other special-focus institutions', 'Schools of law'], dtype=object)




```python
len(cc_details.med_sat_percentile[cc_details.med_sat_percentile.isnull()==True])
```




    2461



## Columns Used


```python
# College completion (new dataset)
cc_cols =[
    'unitid',
    'student_count',
    'awards_per_value',
    'aid_value',
    'endow_value',
    'grad_100_value',
    'grad_150_value',
    'pell_value',
    'retain_value',
    'ft_fac_value']
#     'counted_pct']

# Collegescorecard (old data set)
data_cols = [
    'UNITID',
    'CCUGPROF',
    'HBCU', 
    'MENONLY', 
    'WOMENONLY',
    'TUITFTE', 
    'INEXPFTE',
    'PFTFAC', 
    'AGE_ENTRY',
    'FEMALE', 
    'UGDS_MEN',
    'UGDS_WOMEN',
    'UGDS_WHITE',
    'UGDS_BLACK',
    'UGDS_HISP',
    'UGDS_ASIAN',
    'UGDS_AIAN',
    'UGDS_NHPI',
    'UGDS_2MOR',
    'UGDS_NRA',
    'UGDS_UNKN',
    'UGDS_API']

# descriptive columns from new dataset, not used in model
cc_info_cols = [
    'unitid',
    'city',
    'state',
    'hbcu',
    'basic',
    'site',
    'long_x',
    'lat_y']
```


```python
# use relevant and join data as needed above
cc_det = cc_details[cc_cols].copy()
data_red = data[data_cols].copy()
merge_df = cc_det.merge(data_red,how='left',left_on='unitid',right_on='UNITID')
```


```python
# profile filtered data
start = datetime.now()
profile = pp.ProfileReport(merge_df)
profile.to_file('cc_profile.html')
end = datetime.now()
print('Duration: {}'.format(end-start))
```

    Duration: 0:00:09.441541
    


```python
# NEED TO DROP WHERE PRIVACY SURPRESSED
merge_df2 = merge_df
merge_df2 = merge_df2[merge_df2.AGE_ENTRY!='PrivacySuppressed'].copy()
merge_df2 = merge_df2[merge_df2.FEMALE!='PrivacySuppressed'].copy()
merge_df2.aid_value = merge_df2.aid_value.fillna(merge_df2.aid_value.mean())
merge_df2.pell_value = merge_df2['pell_value'].fillna(merge_df2['pell_value'].mean())
merge_df2.ft_fac_value = merge_df2['ft_fac_value'].fillna(merge_df2['ft_fac_value'].mean())
merge_df2.HBCU = merge_df2.HBCU.fillna(0)
merge_df2.MENONLY = merge_df2.MENONLY.fillna(0)
merge_df2.WOMENONLY = merge_df2.WOMENONLY.fillna(0)
merge_df2.AGE_ENTRY = merge_df2.AGE_ENTRY.astype(float)
merge_df2.AGE_ENTRY = merge_df2.AGE_ENTRY.fillna(merge_df2.AGE_ENTRY.mean())
merge_df2.CCUGPROF = merge_df2.CCUGPROF.fillna(1.0)
merge_df2.FEMALE = merge_df2.FEMALE.astype(float)
merge_df2.FEMALE = merge_df2.FEMALE.fillna(merge_df2.FEMALE.mean()) 
merge_df2.INEXPFTE = merge_df2.INEXPFTE.fillna(merge_df2.INEXPFTE.mean()) 
merge_df2.PFTFAC = merge_df2.PFTFAC.fillna(merge_df2.PFTFAC.mean()) 
merge_df2.TUITFTE = merge_df2.TUITFTE.fillna(merge_df2.TUITFTE.mean()) 
merge_df2.UGDS_2MOR = merge_df2.UGDS_2MOR.fillna(merge_df2.UGDS_2MOR.mean()) 
merge_df2.UGDS_AIAN = merge_df2.UGDS_AIAN.fillna(merge_df2.UGDS_AIAN.mean()) 
merge_df2.UGDS_API = merge_df2.UGDS_API.fillna(merge_df2.UGDS_API.mean()) 
merge_df2.UGDS_ASIAN = merge_df2.UGDS_ASIAN.fillna(merge_df2.UGDS_ASIAN.mean()) 
merge_df2.UGDS_BLACK = merge_df2.UGDS_BLACK.fillna(merge_df2.UGDS_BLACK.mean()) 
merge_df2.UGDS_HISP = merge_df2.UGDS_HISP.fillna(merge_df2.UGDS_HISP.mean()) 
merge_df2.UGDS_MEN = merge_df2.UGDS_MEN.fillna(merge_df2.UGDS_MEN.mean()) 
merge_df2.UGDS_NHPI = merge_df2.UGDS_NHPI.fillna(merge_df2.UGDS_NHPI.mean()) 
merge_df2.UGDS_NRA = merge_df2.UGDS_NRA.fillna(merge_df2.UGDS_NRA.mean()) 
merge_df2.UGDS_UNKN = merge_df2.UGDS_UNKN.fillna(merge_df2.UGDS_UNKN.mean()) 
merge_df2.UGDS_WHITE = merge_df2.UGDS_WHITE.fillna(merge_df2.UGDS_WHITE.mean()) 
merge_df2.UGDS_WOMEN = merge_df2.UGDS_WOMEN.fillna(merge_df2.UGDS_WOMEN.mean()) 
# merge_df2.counted_pct = merge_df2.counted_pct.fillna(merge_df2.counted_pct.mean()) 
merge_df2.endow_value = merge_df2.endow_value.fillna(merge_df2.endow_value.mean()) 
merge_df2.grad_100_value = merge_df2.grad_100_value.fillna(merge_df2.grad_100_value.mean()) 
merge_df2.grad_150_value = merge_df2.grad_150_value.fillna(merge_df2.grad_150_value.mean()) 
merge_df2.retain_value = merge_df2.retain_value.fillna(merge_df2.retain_value.mean())
```


```python
merge_df3 = merge_df2.copy()
# merge_df3 = merge_df3.drop('counted_pct',axis=1)
merge_df3 = merge_df3.drop('UNITID',axis=1)
merge_df3 = merge_df3.drop('HBCU',axis=1)
merge_df3 = merge_df3.drop('MENONLY',axis=1)
merge_df3 = merge_df3.drop('WOMENONLY',axis=1)
# merge_df3 = merge_df2.drop('WOMENONLY',axis=1).copy()
```


```python
# profile filtered data
start = datetime.now()
profile = pp.ProfileReport(merge_df3)
profile.to_file('clean_profile.html')
end = datetime.now()
print('Duration: {}'.format(end-start))
```

    Duration: 0:00:07.789877
    


```python
merge_df3.FEMALE
```




    0       0.564030
    1       0.639091
    2       0.648649
    3       0.476350
    4       0.613419
    5       0.615252
    6       0.603738
    7       0.692948
    8       0.531505
    9       0.520362
    10      0.611966
    11      0.329177
    12      0.762867
    13      0.516588
    14      0.653179
    15      0.638732
    16      0.618061
    17      0.667740
    18      0.631221
    19      0.599134
    20      0.813547
    21      0.470414
    22      0.561086
    23      0.588679
    24      0.650624
    25      0.660555
    26      0.580948
    28      0.568218
    29      0.557759
    30      0.624418
              ...   
    3767    0.817159
    3768    0.605419
    3769    0.605419
    3770    0.605419
    3771    0.605419
    3772    0.605419
    3773    0.750834
    3774    0.750834
    3775    0.750834
    3776    0.605419
    3777    0.794548
    3778    0.627119
    3779    0.605419
    3780    0.605419
    3781    0.605419
    3782    0.605419
    3783    0.802198
    3784    0.605419
    3785    0.813547
    3786    0.750834
    3787    0.640857
    3788    0.573121
    3789    0.266484
    3790    0.495575
    3792    0.514286
    3793    0.526316
    3794    0.485714
    3795    0.896986
    3796    0.620714
    3797    0.605419
    Name: FEMALE, Length: 3701, dtype: float64




```python
# merge_df2 = merge_df.copy()
merge_df2.columns
```




    Index(['unitid', 'student_count', 'awards_per_value', 'aid_value',
           'endow_value', 'grad_100_value', 'grad_150_value', 'pell_value',
           'retain_value', 'ft_fac_value', 'UNITID', 'CCUGPROF', 'HBCU', 'MENONLY',
           'WOMENONLY', 'TUITFTE', 'INEXPFTE', 'PFTFAC', 'AGE_ENTRY', 'FEMALE',
           'UGDS_MEN', 'UGDS_WOMEN', 'UGDS_WHITE', 'UGDS_BLACK', 'UGDS_HISP',
           'UGDS_ASIAN', 'UGDS_AIAN', 'UGDS_NHPI', 'UGDS_2MOR', 'UGDS_NRA',
           'UGDS_UNKN', 'UGDS_API'],
          dtype='object')




```python
merge_df3.columns
```




    Index(['unitid', 'student_count', 'awards_per_value', 'aid_value',
           'endow_value', 'grad_100_value', 'grad_150_value', 'pell_value',
           'retain_value', 'ft_fac_value', 'CCUGPROF', 'TUITFTE', 'INEXPFTE',
           'PFTFAC', 'AGE_ENTRY', 'FEMALE', 'UGDS_MEN', 'UGDS_WOMEN', 'UGDS_WHITE',
           'UGDS_BLACK', 'UGDS_HISP', 'UGDS_ASIAN', 'UGDS_AIAN', 'UGDS_NHPI',
           'UGDS_2MOR', 'UGDS_NRA', 'UGDS_UNKN', 'UGDS_API'],
          dtype='object')




```python
merge_df3.dtypes
```




    unitid                int64
    student_count         int64
    awards_per_value    float64
    aid_value           float64
    endow_value         float64
    grad_100_value      float64
    grad_150_value      float64
    pell_value          float64
    retain_value        float64
    ft_fac_value        float64
    CCUGPROF            float64
    TUITFTE             float64
    INEXPFTE            float64
    PFTFAC              float64
    AGE_ENTRY           float64
    FEMALE              float64
    UGDS_MEN            float64
    UGDS_WOMEN          float64
    UGDS_WHITE          float64
    UGDS_BLACK          float64
    UGDS_HISP           float64
    UGDS_ASIAN          float64
    UGDS_AIAN           float64
    UGDS_NHPI           float64
    UGDS_2MOR           float64
    UGDS_NRA            float64
    UGDS_UNKN           float64
    UGDS_API            float64
    dtype: object




```python
# 'unitid'
# 'student_count'
# 'awards_per_value'
# 'aid_value'
# 'endow_value'
# 'grad_100_value'
# 'grad_150_value'
# 'pell_value'
# 'retain_value'
# 'ft_fac_value'
# 'CCUGPROF'
# 'TUITFTE'
# 'INEXPFTE'
# 'PFTFAC'
# 'AGE_ENTRY'
# 'FEMALE'
# 'UGDS_MEN'
# 'UGDS_WOMEN'
# 'UGDS_WHITE'
# 'UGDS_BLACK'
# 'UGDS_HISP'
# 'UGDS_ASIAN'
# 'UGDS_AIAN'
# 'UGDS_NHPI'
# 'UGDS_2MOR'
# 'UGDS_NRA'
# 'UGDS_UNKN'
# 'UGDS_API'
```


```python
# np.where(np.isnan(merge_df3['UGDS_API']))
```




    (array([], dtype=int64),)



## Initial KMeans for 50 clusters in order to get optimal Cost (Ended up using Elbow and Silhouette to choose 4 clusters)


```python
# The kmeans algorithm is implemented in the scikits-learn library
# runs KMeans for 50 k iterations to find the best k
print('Model 1')
start = datetime.now()
cost = []
ks = []
for k in range (1, 51):
    # Create a kmeans model on our data, using k clusters.  random_state helps ensure that the algorithm returns the same results each time.
    kmeans_model = KMeans(n_clusters=k, random_state=1).fit(merge_df3.loc[:, merge_df3.columns != 'unitid'])
    # These are our fitted labels for clusters -- the first cluster has label 0, and the second has label 1.
    labels = kmeans_model.labels_
    # Sum of distances of samples to their closest cluster center
    interia = kmeans_model.inertia_
    ks.append(k)
    cost.append(interia)
#     print("k:",k, " cost:", interia)
end = datetime.now()
print('Duration: {}'.format(end-start))
# print('Cost Difference:')
# cost_diff = []
# for i,v in enumerate(cost):
#     last = i-1
#     if last < 0:
#         diff = 0
#     else:
#         diff = v - cost[last]
#     cost_diff.append(abs(diff))
#     print('diff: {}'.format(abs(diff)))
        
# print "Dataset: B.csv"
 
# B = pd.read_csv("B.csv")
 
# for k in range (1, 11):
 
#         # Create a kmeans model on our data, using k clusters.  random_state helps ensure that the algorithm returns the same results each time.
#         kmeans_model = KMeans(n_clusters=k, random_state=1).fit(B.iloc[:, :])
 
#         # These are our fitted labels for clusters -- the first cluster has label 0, and the second has label 1.
#         labels = kmeans_model.labels_
        
# 	# Sum of distances of samples to their closest cluster center
# 	interia = kmeans_model.inertia_
#         print "k:",k, " cost:", interia
```

    Model 1
    Duration: 0:00:20.036436
    


```python
# find optimal number of clusters
# uses the difference in cost in each cluster iteration, level out of cost difference can be used to identify the number of clusters
cost_diff.remove(0)
min(cost_diff)
```




    89361003953.19641



## Optimal Clusters Version 2 (Current versions)


```python
# find optimal number of clusters
start = datetime.now()
number_clusters = range(1, 10)

kmeans = [KMeans(n_clusters=i, max_iter = 600) for i in number_clusters]
kmeans

score = [kmeans[i].fit(merge_df3.loc[:, merge_df3.columns != 'unitid']).score(merge_df3.loc[:, merge_df3.columns != 'unitid']) for i in range(len(kmeans))]
score

plt.plot(number_clusters, score)
plt.xlabel('Number of Clusters')
plt.ylabel('Score')
plt.title('Elbow Method')
plt.show()

end = datetime.now()
print('Duration: {}'.format(end-start))
```


![png](output_23_0.png)


    Duration: 0:00:00.899592
    


```python
# Elbow Method v2 (better than above to understand)
sse = []
list_k = list(range(1, 10))

for k in list_k:
    km = KMeans(n_clusters=k)
    km.fit(merge_df3.loc[:, merge_df3.columns != 'unitid'])
    sse.append(km.inertia_)

# Plot sse against k
plt.figure(figsize=(6, 6))
plt.plot(list_k, sse, '-o')
plt.xlabel(r'Number of clusters *k*')
plt.ylabel('Sum of squared distance')
plt.title('SSE of Cluster Points from Centroid')
```




    Text(0.5,1,'SSE of Cluster Points from Centroid')




![png](output_24_1.png)



```python
# Silhouette Coefficient - insight to how well an observation is clustered and provides the average value for observations of each nuber of clusters
from sklearn.metrics import silhouette_samples, silhouette_score
clusters = range(2,12)
for n in clusters:
    n_clusters = n
    clusterer = KMeans(n_clusters=n_clusters, random_state=10)
    cluster_labels = clusterer.fit_predict(merge_df3.loc[:, merge_df3.columns != 'unitid'])
    silhouette_avg = silhouette_score(merge_df3.loc[:, merge_df3.columns != 'unitid'], cluster_labels)
    print("For n_clusters =", n_clusters, "The average silhouette_score is :", silhouette_avg)
```

    For n_clusters = 2 The average silhouette_score is : 0.9621848683283927
    For n_clusters = 3 The average silhouette_score is : 0.9022760644328555
    For n_clusters = 4 The average silhouette_score is : 0.8954561222307392
    For n_clusters = 5 The average silhouette_score is : 0.7778508981979984
    For n_clusters = 6 The average silhouette_score is : 0.5202104558073226
    For n_clusters = 7 The average silhouette_score is : 0.5199220303776945
    For n_clusters = 8 The average silhouette_score is : 0.5212190568746066
    For n_clusters = 9 The average silhouette_score is : 0.5202211110786581
    For n_clusters = 10 The average silhouette_score is : 0.515781011253809
    For n_clusters = 11 The average silhouette_score is : 0.44657114822969834
    

## KMeans modeling


```python
# Fit and Predict clusters with 2 PCA dimensions
# from sklearn.decomposition import PCA
# sklearn_pca = PCA(n_components = 2)
# Y_sklearn = sklearn_pca.fit_transform(merge_df3.loc[:, merge_df3.columns != 'unitid'])
# kmeans = KMeans(n_clusters=4, max_iter=600, algorithm = 'auto')
# fitted = kmeans.fit(Y_sklearn)
# prediction = kmeans.predict(Y_sklearn)

# plt.scatter(Y_sklearn[:, 0], Y_sklearn[:, 1], c=prediction, s=50, cmap='viridis')

# centers = fitted.centroids
# plt.scatter(centers[:, 0], centers[:, 1],c='black', s=300, alpha=0.6)

# add centroids over the scatter

# reduce down to 2 dimensions
sklearn_pca = PCA(n_components = 2)
# transform dataset to 2 dimensions with expection of the primary key
Y_sklearn = sklearn_pca.fit_transform(merge_df3.loc[:, merge_df3.columns != 'unitid'])
# apply KMeans algorithm for the optimal 4 clusters identified above
# test_e = KMeans(n_clusters=4, max_iter=600, algorithm = 'auto')
test_e = KMeans(n_clusters=4, max_iter=600, algorithm = 'auto')
fitted = test_e.fit(Y_sklearn)
predicted_values = test_e.predict(Y_sklearn)
# plot the clusters and their centroids
plt.scatter(Y_sklearn[:, 0], Y_sklearn[:, 1], c=predicted_values, s=50, cmap='viridis')
centers = test_e.cluster_centers_
plt.scatter(centers[:, 0], centers[:, 1],c='black', s=300, alpha=0.6);
```


![png](output_27_0.png)


## Create input records (WIP)


```python
# Create prototype records
cols =['student_count','awards_per_value','aid_value','endow_value','grad_100_value','grad_150_value','pell_value','retain_value','ft_fac_value','CCUGPROF','TUITFTE','INEXPFTE','PFTFAC','AGE_ENTRY','FEMALE','UGDS_MEN','UGDS_WOMEN','UGDS_WHITE','UGDS_BLACK','UGDS_HISP','UGDS_ASIAN','UGDS_AIAN','UGDS_NHPI','UGDS_2MOR','UGDS_NRA','UGDS_UNKN','UGDS_API']
# Low preferences across variables
input1 = [190,11.2,2842,241,0,9.1,18,40,9.6,1,1155.2,2750.4,0.18827,19.748,0.4034,0.1461,0.3842,0.0127,0.0113,0.0003,0,0.0017,0,0,0,0,0]
# student1 = student1.reshape(1,-1)
# medium preferences across variables
input2 = [1851,21.4,5173,26394,25.5,42.138,44.7,65.971,41.3,5,14064,7073.5,0.58456,24.461,0.60542,0.41005,0.58935,0.5407,0.1072,0.0892,0.0214,0.0042,0.0014,0.0297,0.013,0.0281,0.0079]
# kmeans.predict(student2)
# high preferences across variables
input3 = [19063,43,21327,60936,72.4,81.6,82.7,91.3,90,14,24519,16942,1,30.852,0.83415,0.6154,0.8523,0.8566,0.6161,0.4837,0.1429,0.0346,0.0107,0.0721,0.1058,0.1536,0.0937]

# Create samples to input into model
# ***** SHOULD CREATE AND INPUT AT LEAST 3-4 RECORDS AS MODEL REQUIRES MULTIPLE SAMPLES

# *** Each student will have 3 or 5 inputs
# Each input will be based on the importance of the TOP student preferences identified in the survey
# Each input will change the with the most important down the preference list

# inputs1 = pd.DataFrame([student1,student2],columns=cols)
# inputs2 = pd.DataFrame([student2,student3],columns=cols)
# inputs3 = pd.DataFrame([student1,student3],columns=cols)
student1 = pd.DataFrame([input1,input2,input1,input2],columns=cols)
student2 = pd.DataFrame([input2,input3,student2,student3],columns=cols)
student3 = pd.DataFrame([input1,input3,input1,input3],columns=cols)
# inputs1.shape
# inputs2.shape
# inputs3.shape

# Apply PCA to input records
sklearn_pca = PCA(n_components = 2)
Y_inputs1 = sklearn_pca.fit_transform(inputs1)
Y_inputs2 = sklearn_pca.fit_transform(inputs2)
Y_inputs3 = sklearn_pca.fit_transform(inputs3)

# apply KMeans algorithm to input records
out1 = kmeans.fit_predict(Y_inputs1)
out2 = kmeans.fit_predict(Y_inputs2)
out3 = kmeans.fit_predict(Y_inputs3)
print(out1)
print(out2)
print(out3)
```

    [2 1 0 3]
    [2 0 1 3]
    [1 3 1 0]
    


```python
labels = fitted.labels_
len(labels)
```




    3701




```python
unique_elements, counts_elements = np.unique(labels, return_counts=True)
print("Frequency of unique values of the said array:")
print(np.asarray((unique_elements, counts_elements)))
```

    Frequency of unique values of the said array:
    [[   0    1    2    3]
     [3623   15   61    2]]
    


```python
len(merge_df3)
```




    3701




```python
# append cluster labels to data for filtering
label_lst = labels.tolist()
labeled_df = merge_df3
labeled_df['cluster'] = label_lst
```


```python
labeled_df.cluster.value_counts()
```




    0    3623
    2      61
    1      15
    3       2
    Name: cluster, dtype: int64



## Join descriptive columns back (WIP)


```python


labeled_df.to_csv('final_data.csv')
```


```python
# MAY WANT TO LOOK INTO MORE CLUSTERS, POOR DISTRIBUTION ACROSS CLUSTERS, RECOMMENDATIONS STEMMING FROM SINGLE CLUSTER WILL NOT BE VALUABLE
# CODE EXISTS FOR 4 AND 5 CLUSTERS
# Notes
# Makes sense that schools are similar. But need enough differentiation to provide a valuable recommendation ranking.
# Expanding clusters assists in differentiation. 
```
