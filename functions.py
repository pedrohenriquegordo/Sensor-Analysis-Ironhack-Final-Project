###################################################
###################################################
#########               Imports            ########
###################################################
###################################################

#Ignore warnings:
import warnings
warnings.filterwarnings('ignore')

# Handle files
import os
import json
from pandas.io.json import json_normalize
from joblib import Parallel, delayed

# Data manipulating
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.preprocessing import MinMaxScaler

#Connection to mysql
from sqlalchemy import create_engine
user = 'root'
password = '******'
host = 'localhost'
port = 3306
database = 'final_project_database'
engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}")
import mysql.connector
connection = mysql.connector.connect(host=host,user=user,password=password,database=database)

#Graphics:
import matplotlib.pyplot as plt
import seaborn as sns

#Models:
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import RandomizedSearchCV
import numpy as np



###################################################
#########           End Imports            ########
###################################################

###################################################
###################################################
#########              Functions           ########
###################################################
###################################################


################################
#### Extractiton Functions  ####
################################

def convert_column_json_to_dict(column):
    column=column.apply(lambda x:json.loads(x))
    return column

def extract_dfs(data):
    data['info']=convert_column_json_to_dict(data['info'])

    temp_dfs=[]
    for i in range(len(data['info'])):
        short_df=pd.DataFrame.from_dict(data['info'][i], orient='index').T
        temp_dfs.append(short_df)
    temp_df=pd.concat(temp_dfs, axis=0, ignore_index=True)
    temp_df.index=data['date']
    
    if 'feedback' in temp_df.columns:
        feedback=temp_df[['device','state','feedback']]
    else:
        feedback=temp_df[['device','state']]
        feedback['feedback']=None

    thp_sensors=temp_df[['temperature','humidity','pressure','linkquality']]
    thp_sensors.dropna(subset='linkquality',inplace=True)

    dw_sensors=temp_df[['contact','linkquality']]

    motion_sensors=temp_df[['illuminance','occupancy']]

    met_cond=temp_df[['temperature','humidity','pressure','description','windspeed']]
    met_cond.dropna(subset='windspeed',inplace=True)
    
    dfs=[feedback,thp_sensors,dw_sensors,motion_sensors,met_cond]
        
    return dfs

def split_index(x):
    date, time = x.split(' ')
    time, trash = time.split('+')
    time = time[:-7]
    return date, time   
    
def arrange_date(x):
    year=x[:4]
    month=x[5:7]
    day=x[8:10]
    return day+'-'+month+'-'+year

def date_time_magic(df):
    df['date']=pd.DataFrame(df['date'].apply(lambda x: arrange_date(x)).to_list(), index=df.index)
    date=df.pop('date')
    df.insert(len(df.columns),'date',date)
    return df

def split_description(x):
    local,date_time=x.split(' @ ')
    return local,date_time

def date_time_met_cond(x):
    date,time=x.split('T')
    year=x[:4]
    month=x[5:7]
    day=x[8:10]
    date=day+'-'+month+'-'+year
    time=time+':'+'00'
    return [time,date]

#########################
## Cleaning Functions  ##
#########################

def valid_temp(x):
    return x if 11.22 <= x <= 35.51 else np.nan

def valid_hum(x):
    return x if 26.78 <= x <= 96.1 else np.nan

def valid_pre(x):
    return x if 922.0 <= x <= 1032.8 else np.nan


def thp_data_clean(thp_data):

    thp_data['date']=thp_data['date'] = pd.to_datetime(thp_data['date'])
    thp_data['in_temp'].apply(lambda x: valid_temp(x))
    thp_data['in_hum'].apply(lambda x: valid_hum(x))
    thp_data['in_pre'].apply(lambda x: valid_pre(x))

    return thp_data


######################
## Graph Functions  ##
######################

def plot_var(thp_data):

    tenants=thp_data['tenant_id'].unique()

    colors=['darkorange','teal','green','deeppink','darkorchid','chocolate']

    columns=thp_data.drop(['tenant_id','hour','date'],axis=1).columns

    titles_dict={'in_temp':'Temperature Inside', 'out_temp':'Temperature Outside',
                'in_hum':'Humidity Inside', 'out_hum':'Humidity Outside',
                'in_pre':'Pressure Inside', 'out_pre':'Pressure Outside'}


    fig, axes = plt.subplots(nrows=3, ncols=2, figsize=(15, 15))

    for row, category in enumerate(['temp', 'hum', 'pre']):
        for col, position in enumerate(['in', 'out']):
            graph_title = f'{position}_{category}'

            for i in range(len(tenants)):
                color = colors[i]
                df = thp_data[thp_data['tenant_id'] == tenants[i]]

                sns.kdeplot(df[graph_title], shade=True, alpha=0.15, lw=1.25, color=color, label=f'Tenant {tenants[i]}', ax=axes[row, col])
                axes[row, col].set_title(f'{titles_dict[graph_title]}')

            if category == 'temp':
                #axes[row, col].set_xlim([0, 40])
                axes[row, col].set_xlabel(f'{titles_dict[graph_title]} (°C)')

            elif category == 'hum':
                axes[row, col].axvline(x=100, linestyle='--', lw=0.75, color='black')
                #axes[row, col].set_xlim([0, 130])
                axes[row, col].set_xlabel(f'{titles_dict[graph_title]} (RH%)')

            else:
                #axes[row, col].set_xlim([990, 1040])
                axes[row, col].set_xlabel(f'{titles_dict[graph_title]} (mbar)')

            axes[row, col].legend()

    plt.show()

def arrange_graph(var, pos, axes, i):
    label_={'temp': ['Temperature',' (°C)'],'hum': ['Humidity',' (RH%)'],'pre': ['Pressure',' (mbar)']}
    axes[pos].set_title(f'{var.capitalize()} Data from Tenant {i}')
    axes[pos].set_xlabel(f'{label_[var]}')
    axes[pos].legend()
    
def arrange_graph_1(var_x, var_y, pos, axes, title_prefix=''):
    label_={'temp': ['Temperature',' (°C)'],'hum': ['Humidity',' (RH%)'],'pre': ['Pressure',' (mbar)']}
    axes[pos].set_title(f'{title_prefix}{label_[var_y][0]}')
    axes[pos].set_xlabel(f'{var_x.capitalize()}')
    axes[pos].set_ylabel(f'{label_[var_y][0]} {label_[var_y][1]}')

def plot_in_vs_out(thp_data, tenant=None):

    df = thp_data if tenant is None else thp_data[thp_data['tenant_id'] == tenant]

    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5))
        
    #temperature
    sns.kdeplot(df['in_temp'], shade=True, alpha=0.15, lw=1.25, color='red', label='Temperature Inside', ax=axes[0])
    sns.kdeplot(df['out_temp'], shade=True, alpha=0.15, lw=1.25, color='darkred', label='Temperature Outside', ax=axes[0])
    arrange_graph('temp', 0, axes, tenant)

    #humidity
    sns.kdeplot(df['in_hum'], shade=True, alpha=0.15, lw=1.25, color='deepskyblue', label='Humidity Inside', ax=axes[1])
    sns.kdeplot(df['out_hum'], shade=True, alpha=0.15, lw=1.25, color='blue', label='Humidity Outside', ax=axes[1])
    axes[1].axvline(x=100, linestyle='--', lw=0.75, color='black')
    arrange_graph('hum', 1, axes, tenant)

    #pressure
    sns.kdeplot(df['in_pre'], shade=True, alpha=0.15, lw=1.25, color='limegreen', label='Pressure Inside', ax=axes[2])
    sns.kdeplot(df['out_pre'], shade=True, alpha=0.15, lw=1.25, color='green', label='Pressure Outside', ax=axes[2])
    arrange_graph('pre', 2, axes, tenant)
        
    plt.show()

def plot_mean(thp_data, var_x, tenant=None, month=None):
    
    df=thp_data

    df['day'] = thp_data['date'].dt.day
    df['month'] = thp_data['date'].dt.month
    
    if tenant is not None:
        df = df[df['tenant_id'] == tenant]

    if month is not None:
        df = df[df['month'] == month]
    
    x = var_x
    
    title_prefix = f'Tenant {tenant} ' if tenant is not None else ''
    
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5), gridspec_kw={'hspace': 0.4})
    
    # Temperature
    var_y = df['in_temp']
    sns.lineplot(data=df, x=x, y='in_temp', color='red', label='Temperature Inside', ax=axes[0])
    arrange_graph_1(var_x, 'temp', 0, axes, title_prefix)

    # Humidity
    var_y = df['in_hum']
    sns.lineplot(data=df, x=x, y='in_hum', color='deepskyblue', label='Humidity Inside', ax=axes[1])
    arrange_graph_1(var_x, 'hum', 1, axes, title_prefix)

    # Pressure
    var_y = df['in_pre']
    sns.lineplot(data=df, x=x, y='in_pre', color='limegreen', label='Pressure Inside', ax=axes[2])
    arrange_graph_1(var_x, 'pre', 2, axes, title_prefix)
    
    plt.show()
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5), gridspec_kw={'hspace': 0.4})
    
    # Temperature
    var_y = df['out_temp']
    sns.lineplot(data=df, x=var_x, y='out_temp', color='darkred', label='Temperature Outside', ax=axes[0])
    arrange_graph_1(var_x, 'temp', 0, axes, title_prefix)

    # Humidity
    var_y = df['out_hum']
    sns.lineplot(data=df, x=var_x, y='out_hum', color='blue', label='Humidity Outside', ax=axes[1])
    arrange_graph_1(var_x, 'hum', 1, axes, title_prefix)

    # Pressure
    var_y = df['out_pre']
    sns.lineplot(data=df, x=var_x, y='out_pre', color='green', label='Pressure Outside', ax=axes[2])
    arrange_graph_1(var_x, 'pre', 2, axes, title_prefix)

    plt.show()

def heat_map(thp_data):


    titles_dict={'in_temp':'Temperature Inside', 'out_temp':'Temperature Outside',
                'in_hum':'Humidity Inside', 'out_hum':'Humidity Outside',
                'in_pre':'Pressure Inside', 'out_pre':'Pressure Outside'}

    for tenant in thp_data['tenant_id'].unique():
        df=thp_data[thp_data['tenant_id']==tenant]
        df=df.drop(['tenant_id','hour','date','month','day'],axis=1)
        correlation_matrix = df.corr()
        correlation_matrix.rename(columns=titles_dict, index=titles_dict, inplace=True)
        plt.figure(figsize=(10, 6))
        sns.heatmap(correlation_matrix, annot=True, cmap='PRGn',lw=7, vmin=-1, vmax=1)
        plt.title(f'Heatmap for Data from tenant {tenant}')
    plt.show()

###################################################
#########           STATS          ################
###################################################

def apply_stats(df, group, col, g1, g2):
    
    import numpy as np
    from scipy import stats

    group=df.groupby(group)

    comfort_in_temp = group.get_group(g1)[col]
    uncomfort_in_temp = group.get_group(g2)[col]

    t_stat, p_value = stats.ttest_ind(comfort_in_temp, uncomfort_in_temp)

    print("t-statistic:", round(t_stat,2))
    print("p-value:", round(p_value,4))

    alpha = 0.05

    if p_value < alpha:
        a=1
        return f'There\'s no significative diference between {col} for groups {g1} and {g2}.'
    else:
        a=0
        return f'There is a significative diference between {col} for groups {g1} and {g2}.'
    

###################################################
#########           Models           ##############
###################################################



def apply_lr(X_train, X_test, y_train, y_test):

    model=LinearRegression()
    model.fit(X_train, y_train)

    y_pred=model.predict(X_test)

    mse_lr=mean_squared_error(y_test, y_pred).round(2)
    r2_lr=r2_score(y_test, y_pred).round(2)

    return [mse_lr, r2_lr]

def apply_dtr(X_train, X_test, y_train, y_test):

    model=DecisionTreeRegressor()
    model.fit(X_train, y_train)

    y_pred=model.predict(X_test)

    mse_dt=mean_squared_error(y_test, y_pred).round(2)
    r2_dt=r2_score(y_test, y_pred).round(2)

    return [mse_dt,r2_dt]

def apply_rfr(X_train, X_test, y_train, y_test):
    model=RandomForestRegressor()
    model.fit(X_train, y_train)

    y_pred=model.predict(X_test)

    mse_rf=mean_squared_error(y_test, y_pred).round(2)
    r2_rf=r2_score(y_test, y_pred).round(2)

    r.append(r2_rf)
    m.append(mse_rf)

    return [mse_rf,r2_rf]

def folds(k, X, y):
    model=RandomForestRegressor()
    
    k=5
    r2_scores=cross_val_score(model, X, y, cv=k, scoring='r2')

    r2_mean=r2_scores.mean().round(2)
    r2_std=r2_scores.std().round(2)

    print(f"R² scores: {r2_scores}")
    print(f"R² mean: {r2_mean}")
    print(f"R² std: {r2_std}")

def best_combo(X_train, y_train, X_test, y_test, param_dist):

    model = RandomForestRegressor()

    random_search = RandomizedSearchCV(model, param_dist, n_iter=20, cv=5, scoring='r2', n_jobs=-1, random_state=42)

    random_search.fit(X_train, y_train)

    best_model = random_search.best_estimator_

    y_pred = best_model.predict(X_test)

    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)

    return best_model, mse, r2

###################################################
###################################################
###################################################
###################################################
