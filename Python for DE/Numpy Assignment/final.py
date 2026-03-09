import pandas as pd 
from datetime import date 
from datetime import datetime
import matplotlib.pyplot as plt
from json import loads, dumps
import logging
import time

def setup_logging() -> logging.Logger:
    logger = logging.getLogger("pipeline")
    logger.setLevel(logging.DEBUG)

    fmt = logging.Formatter(
        "%(asctime)s | %(levelname)-8s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    # Console: show INFO and above
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(fmt)

    # File: capture everything (DEBUG+)
    fh = logging.FileHandler("pipeline.log")
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(fmt)

    logger.addHandler(ch)
    logger.addHandler(fh)
    return logger



def data_loading(df,logger: logging.Logger):
    time.sleep(2)
    logger.info("###### Task [load] starting ######")

    # The age column is being recognized as float64 which should be int 
    df['Age'] = df['Age'].astype('Int64')

    print("\n#### Sample of the dataset ####")
    print(df.head())

    logger.info(f"The total number of records in the dataset: {len(df)}")

    logger.info("The schema of dataset")
    for col,dtype in df.dtypes.items():
        logger.info(f"{col} : {dtype}")

    logger.info("###### Task [load] ending ######")
    logger.info("")
    return df

def data_cleaning(df,logger:logging.Logger):
    time.sleep(2)
    logger.info("###### Task [cleaning] starting ######")

    # The age column is being recognized as float64 which should be int 
    df['Age'] = df['Age'].astype('Int64')
    

    missing_val_columns = []

    # Check if entire DataFrame has any null values and if yes then append the column names to list 
    if df.isnull().values.any():
        for i in df.columns:
            if df[f'{i}'].isnull().any():
                missing_val_columns.append(i)

    # Replace missing Age values using the median of the available data.
    logger.info("Filling the blank age values with its median")
    median_age = int(df["Age"].median())
    df["Age"] = df["Age"].fillna(median_age)
    

    # Replace missing Salary values using the mean of the available data.
    logger.info("Filling the blank salary values with its mean")
    mean_salary = int(df["Salary"].mean())
    df["Salary"] = df["Salary"].fillna(mean_salary)

    # Detect and remove duplicate employee records based on Employee_ID.
    logger.info("Dropping the duplicates based on employee id")
    df = df.drop_duplicates(subset = ['Employee_ID'])

    logger.info("###### Task [cleaning] ending ######")
    return df

def data_manipulation(df,logger:logging.Logger):
    time.sleep(2)

    logger.info("")
    logger.info("###### Task [manipulation] starting ######")

    logger.info(f"Number of records before filtering: {len(df)}")

    # Filter out employees who are above the age of 25 or have a salary above 40,000, and are not resigned.
    filtered_df = df[(df['Resigned'] == False) & ((df['Age'] > 25) | (df['Salary'] > 400000))]

    # Create a new column YearsInCompany by calculating the number of years each employee has worked in the company (from JoiningDate to today). 
    filtered_df['Joining_Date'] = pd.to_datetime(filtered_df['Joining_Date'],format = "%d/%m/%Y", errors = 'coerce')
    today = pd.Timestamp(date.today())
    filtered_df['YearsInCompany'] = ((today - filtered_df['Joining_Date']).dt.days // 365).astype('Int64')

    logger.info(f"Number of records after filtering: {len(filtered_df)}")
    
    logger.info("###### Task [manipulation] ending ######")

    return filtered_df

def data_aggregation(filtered_df,logger:logging.Logger):
    time.sleep(2)

    logger.info("")
    logger.info("###### Task [aggregation] starting ######")
    # Compute department-level statistics including average salary and median age.
    logger.info("Department-level statisitics: Average Salary")

    logger.info(filtered_df.groupby('Department')['Salary'].mean())
    logger.info("\nDepartment-level statisitics: Median Age")
    logger.info(filtered_df.groupby('Department')['Age'].median())

    # Apply a salary increment of 10% for employees belonging to a specific department.
    # Will apply 10% percent raise to the IT department :D
    logger.info("Incremented the salary of IT staff by 10 percent")
    IT_df = filtered_df[filtered_df['Department'] == "IT"]
    IT_df['Salary'] = IT_df['Salary']*1.1 

    Non_IT_df = filtered_df[filtered_df['Department'] != "IT"]

    ff_df = pd.concat([IT_df,Non_IT_df])
    logger.info("###### Task [aggregation] ending ######")

    return ff_df

def data_trans_export(ff_df,logger:logging.Logger):
    time.sleep(2)

    logger.info("")
    logger.info("###### Task [Data transportation export] starting ######")

    ff_df = ff_df.sort_values(by = 'Joining_Date',ascending = False)
    # Retain only relevant fields in the final dataset (Employee_ID, Name, Age, Department, Salary, and YearsInCompany).
    relevant_data = ff_df.loc[:,['Employee_ID','Name','Age','Department','Salary','YearsInCompany']]


    # Export the final dataset to JSON format.
    json_dataset = relevant_data.to_json("employees.json",orient="columns")
    logger.info("Exported the data to json successfully")
    logger.info(f"The record count is {len(relevant_data)}")

    logger.info("###### Task [Data transportation export] starting ######")
    return relevant_data

def run_pipeline():
    logger = setup_logging()
    logger.info("##############################")
    logger.info("###### PIPELINE STARTED ######")
    logger.info("##############################")
    logger.info("")
    
    df = pd.read_csv(r'C:\Users\aman.rajput\Downloads\Numpy Assignment\employees.csv')
    rd = data_loading(df,logger)
    cd = data_cleaning(rd,logger)
    md = data_manipulation(cd,logger)
    ad = data_aggregation(md,logger)
    dte = data_trans_export(ad,logger)

    logger.info("")
    logger.info("##############################")
    logger.info("###### PIPELINE COMPLETE ######")
    logger.info("##############################")
    
    

run_pipeline()