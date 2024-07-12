import psycopg2
import pandas as pd
import numpy as np
import streamlit as st
from datetime import datetime
import plotly.express as px
import warnings
import plotly.graph_objects as go
warnings.filterwarnings('ignore')
import matplotlib.pyplot as plt
from PIL import Image
import os
import base64



st.set_page_config(layout="wide")

st.title(" ")
st.title(":hospital: Hospital Data Analysis")
st.markdown('<style>div.block-container{padding-top:1rem;}</style>', unsafe_allow_html=True)

# toggle session state
if 'mode' not in st.session_state:
    st.session_state.mode = "Table"  

col1, col2 ,col3= st.sidebar.columns(3)
if col1.button("Table Mode"):
    st.session_state.mode = "Table"
if col2.button("Dash board"):
    st.session_state.mode = "Visualization"
if col3.button("Patients"):
    st.session_state.mode = "Patients"

#  database connection
def get_db_connection():
    conn = psycopg2.connect(
        dbname="newdb",
        user="postgres",
        password="2003",
        host="localhost",
        port="5432"
    )
    return conn
#  table relationships
def get_table_relationships(conn):
    query = """
    SELECT
        LOWER(tc.table_name) AS parent_table,
        LOWER(kcu.column_name) AS parent_column,
        LOWER(ccu.table_name) AS child_table,
        LOWER(ccu.column_name) AS child_column
    FROM
        information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
            ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
            ON ccu.constraint_name = tc.constraint_name
            AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
    """
    relationships = pd.read_sql(query, conn)
    return relationships

# primary keys
def get_primary_keys(conn):
    query = """
    SELECT
        LOWER(tc.table_name) AS table_name,
        LOWER(kcu.column_name) AS column_name
    FROM
        information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
            ON tc.constraint_name = kcu.constraint_name
            AND tc.table_schema = kcu.table_schema
    WHERE tc.constraint_type = 'PRIMARY KEY'
    """
    primary_keys = pd.read_sql(query, conn)
    return primary_keys

#  find related tables
def find_related_tables(start_table, relationships, visited=None):
    if visited is None:
        visited = set()
    related_tables = relationships[relationships['parent_table'] == start_table]['child_table'].tolist()
    related_tables += relationships[relationships['child_table'] == start_table]['parent_table'].tolist()

    for table in related_tables:
        if table not in visited:
            visited.add(table)
            find_related_tables(table, relationships, visited)

    return visited

def get_table_data(conn, table_name):
    query = f"SELECT * FROM {table_name}"
    try:
        data = pd.read_sql(query, conn)
        data = cast_column_types(data)
        return data
    except Exception as e:
        st.error(f"Error loading data for table {table_name}: {e}")
        return pd.DataFrame()

def cast_column_types(data):
    for col in data.columns:
        if col.endswith('id'):
            data[col] = pd.to_numeric(data[col], errors='coerce')
    return data

def trim_whitespace(data):
    return data.applymap(lambda x: x.strip() if isinstance(x, str) else x)


# enhance patient data
def enhance_patient_data(patient_data):
    if 'dob' in patient_data.columns:
        current_date = datetime.now()
        patient_data['age'] = patient_data['dob'].apply(
            lambda dob: current_date.year - pd.to_datetime(dob).year
            - ((current_date.month, current_date.day) < (pd.to_datetime(dob).month, pd.to_datetime(dob).day))
        )

        def assign_unit(age):
            if age <= 15:
                return 'pediatric'
            elif 15 < age <= 30:
                return 'unit1'
            elif 30 < age <= 40:
                return 'unit2'
            elif 40 < age <= 50:
                return 'unit3'
            else:
                return 'unit4'

        patient_data['unit'] = patient_data['age'].apply(assign_unit)
    else:
        st.warning("DOB column not found in patients table.")

    return patient_data


#  merge tables
def merge_tables(tables, relationships):
    merged_table = None
    merge_order = []

    if 'patients' in tables:
        merged_table = tables['patients']
        merge_order.append('patients')

    # Directly merge tables with patientid
    for table_name, table_data in tables.items():
        if table_name == 'patients':
            continue
        if 'patientid' in table_data.columns:
            if merged_table is None:
                merged_table = table_data
            else:
                merged_table = pd.merge(
                    merged_table,
                    table_data,
                    on='patientid',
                    how='outer',
                    suffixes=('', f'_{table_name}')
                )
            merge_order.append(table_name)

    for table_name, table_data in tables.items():
        if table_name == 'patients' or 'patientid' in table_data.columns:
            continue
        parent_relation = relationships[relationships['child_table'] == table_name]
        if not parent_relation.empty:
            parent_table = parent_relation['parent_table'].iloc[0]
            parent_column = parent_relation['parent_column'].iloc[0]
            child_column = parent_relation['child_column'].iloc[0]

            if parent_table in tables:
                try:
                    tables[parent_table] = cast_column_types(tables[parent_table])
                    table_data = cast_column_types(table_data)

                    merged_table = pd.merge(
                        merged_table,
                        table_data,
                        left_on=parent_column,
                        right_on=child_column,
                        how='outer',
                        suffixes=('', f'_{table_name}')
                    )
                    merge_order.append(table_name)
                except Exception as e:
                    st.error(f"Error merging {table_name}: {e}")
        else:
            st.warning(f"No parent relationship found for table: {table_name}")

    return merged_table, merge_order

# Function to filter foreign keys from columns
def filter_foreign_keys(table_columns, table_name, relationships, primary_keys):
    foreign_keys = relationships[relationships['parent_table'] == table_name]['child_column'].tolist()
    foreign_keys += relationships[relationships['child_table'] == table_name]['parent_column'].tolist()
    primary_key_columns = primary_keys[primary_keys['table_name'] == table_name]['column_name'].tolist()

    # Remove both foreign keys and primary keys
    filtered_columns = [col for col in table_columns if col not in foreign_keys and col not in primary_key_columns]
    return filtered_columns

# Define categorical columns and date columns
categorical_columns = ['gender', 'unit']  # Add more categorical columns as needed
date_columns = ['dob']  # Add more date columns as needed

# Function to apply filters on merged table
def apply_filters(merged_table, filters, categorical_columns):
    for column, filter_value in filters.items():
        if column in categorical_columns:
            if isinstance(filter_value, list):
                merged_table = merged_table[merged_table[column].isin(filter_value)]
        else:
            pass  # Handle other columns with specific filter requirements if needed
    return merged_table

def create_gauge_chart(value, title, max_value):
    fig = go.Figure(go.Indicator(
        mode="gauge+number",
        value=value,
        title={'text': title, 'font': {'size': 24}},
        domain={'x': [0, 1], 'y': [0, 1]},
        number={'font': {'color': "black", 'size': 40}},  # Change the number color to black and increase size
        gauge={
            'axis': {'range': [None, max_value], 'visible': False},
            'bar': {'color': "rgb(0, 150, 255)"},
            'bgcolor': "white",
            'borderwidth': 2,
            'bordercolor': "gray",
            'steps': [
                {'range': [0, max_value], 'color': "white"}
            ],
            'threshold': {
                'line': {'color': "white", 'width': 4},
                'thickness': 0.75,
                'value': max_value
            }
        }
    ))
    
    fig.update_layout(
        height=300,
        width=300,
        margin=dict(l=10, r=10, t=50, b=10, pad=8),
        paper_bgcolor="white",
        font={'color': "darkgray", 'family': "Arial"}
    )
    
    return fig


def show_visualizations(merged_table):
    st.markdown('<style>div.block-container{padding-top:1rem;}</style>', unsafe_allow_html=True)
    # Calculate counts
    patient_count = merged_table["patientid"].nunique()
    doctor_count = merged_table["doctorid"].nunique()
    nurse_count = merged_table["nurseid"].nunique()
    appointment_count = merged_table["appointmentid"].nunique()
    pending_appointment_count = merged_table[merged_table["status"] == "Scheduled"]["appointmentid"].nunique()
    completed_appointment_count = merged_table[merged_table["status"] == "Completed"]["appointmentid"].nunique()

    # Display counts
    st.markdown(
        f"""
        <style>
            .box {{
            display: inline-block;
            width: 200px;
            height: 150px;
            text-align: center;
            background-color: lightgrey;
            border: 1px solid black;
            border-radius: 5px;
            padding: 20px;
            margin: 10px;
        }}
        .container {{
            display: flex;
            justify-content: space-around;
            margin-bottom: 20px;
        }}
        </style>
        <div class='container'>
            <div class='box'>
                <h2>{patient_count}</h2>
                <p>Patients</p>
            </div>
            <div class='box'>
                <h2>{doctor_count}</h2>
                <p>Doctors</p>
            </div>
            <div class='box'>
                <h2>{nurse_count}</h2>
                <p>Nurses</p>
            </div>
            <div class='box'>
                <h2>{appointment_count}</h2>
                <p>Appointments</p>
            </div>
            <div class='box'>
                <h2>{pending_appointment_count}</h2>
                <p>Scheduled appointments</p>  
             </div>
            <div class='box'>  
                <h2>{completed_appointment_count}</h2>
                <p>Completed appointments</p>             
            </div>
        </div>
        """,
        unsafe_allow_html=True
    )
    
            
    # Sidebar filters
    st.sidebar.header("Choose your filters:")

    # Define filter options
    filter_options = {
    "gender": merged_table["gender"].unique(),
    "city": merged_table["city"].unique(),
    "specialization": merged_table["specialization"].unique(),
    "paymentstatus": merged_table["paymentstatus"].unique(),
    "reason": merged_table["reason"].unique()
}
    # Initialize dictionary to hold selected filter values
    selected_filters = {}

    # Create dropdowns for each filter type
    for filter_type, values in filter_options.items():
        selected_filters[filter_type] = st.sidebar.multiselect(f"Select {filter_type}", values)

    # Apply filters based on user selection
    filtered_df = merged_table.copy()
    for filter_type, selected_values in selected_filters.items():
        if selected_values:
            filtered_df = filtered_df[filtered_df[filter_type].isin(selected_values)]

    # Gauge charts
    col_gauge1, col_gauge2, col_gauge3, col_gauge4, col_gauge5, col_gauge6 = st.columns(6)

    with col_gauge1:
        fig_gauge_patients = create_gauge_chart(patient_count, "Total Patients", patient_count * 1.5)
        st.plotly_chart(fig_gauge_patients, use_container_width=True)

    with col_gauge2:
        fig_gauge_appointments = create_gauge_chart(appointment_count, "Total Appointments", appointment_count * 1.5)
        st.plotly_chart(fig_gauge_appointments, use_container_width=True) 
        
    with col_gauge3:
        fig_gauge_doctors = create_gauge_chart(doctor_count, "Total Doctors", doctor_count * 1.5)
        st.plotly_chart(fig_gauge_doctors, use_container_width=True) 

    with col_gauge4:
        fig_gauge_nurses = create_gauge_chart(nurse_count, "Total Nurses", nurse_count * 1.5)
        st.plotly_chart(fig_gauge_nurses, use_container_width=True) 

    with col_gauge5:
        fig_gauge_scheduled = create_gauge_chart(pending_appointment_count, "Scheduled appnts.", pending_appointment_count * 1.5)
        st.plotly_chart(fig_gauge_scheduled, use_container_width=True) 
        
    with col_gauge6:
        fig_gauge_completed = create_gauge_chart(completed_appointment_count, "Completed appnts.", completed_appointment_count * 1.5)
        st.plotly_chart(fig_gauge_completed, use_container_width=True)

    # Layout for the dashboard
    col1, col2, col3,col4 = st.columns(4)
    col5, col6, col7 ,col8 = st.columns(4)
   
    # Age Distribution
    with col1:
        fig = px.histogram(filtered_df, x="unit", nbins=20, title="Age Distribution")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)

    # Appointment Status
    with col2:
        status_df = filtered_df.groupby(["appointmentdate", "status"]).size().reset_index(name='counts')
        fig = px.bar(status_df, x="appointmentdate", y="counts", color="status", title="Appointment Status")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)

    # Specialization Demand
    with col3:
        specialization_df = filtered_df["specialization"].value_counts().reset_index()
        specialization_df.columns = ["specialization", "count"]
        fig = px.pie(specialization_df, names="specialization", values="count", title="Specialization Demand")
        fig.update_traces(textinfo='percent+label', textfont_size=12, hovertemplate='%{label}: %{value} (%{percent})<extra></extra>')
        st.plotly_chart(fig, use_container_width=True)

    # Payment Status
    with col4:
        payment_df = filtered_df["paymentstatus"].value_counts().reset_index()
        payment_df.columns = ["paymentstatus", "count"]
        fig = px.pie(payment_df, names="paymentstatus", values="count", title="Payment Status")
        fig.update_traces(textinfo='percent+label', textfont_size=12, hovertemplate='%{label}: %{value} (%{percent})<extra></extra>')
        st.plotly_chart(fig, use_container_width=True)

    # Common Diagnoses
    with col5:
        diagnosis_df = filtered_df["treatmentname"].value_counts().reset_index()
        diagnosis_df.columns = ["treatmentname", "count"]
        fig = px.bar(diagnosis_df, x="treatmentname", y="count", title="Common Diagnoses")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)
    
    # Common Symptoms
    with col6:
        symptom_df = filtered_df["symptomname"].value_counts().reset_index()
        symptom_df.columns = ["symptomname", "count"]
        fig = px.bar(symptom_df, x="symptomname", y="count", title="Common Symptoms")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)

    

    # Doctor Utilization
    with col7:
        doctor_df = filtered_df["doctor_firstname"].value_counts().reset_index()
        doctor_df.columns = ["doctor_firstname", "count"]
        fig = px.bar(doctor_df, x="doctor_firstname", y="count", title="Doctor Utilization")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)

    # Nurse Workload
    with col8:
        nurse_df = filtered_df["nurse_firstname"].value_counts().reset_index()
        nurse_df.columns = ["nurse_firstname", "count"]
        fig = px.bar(nurse_df, x="nurse_firstname", y="count", title="Nurse Workload")
        fig.update_traces(texttemplate='%{y}', textposition='outside', textfont_size=12)
        fig.update_layout(bargap=0.1)
        st.plotly_chart(fig, use_container_width=True)

 

    # Department Utilization
    department_df = filtered_df.groupby(["departmentname", "doctor_firstname"]).size().reset_index(name='counts')
    fig = px.treemap(department_df, path=["departmentname", "doctor_firstname"], values="counts", title="Department Utilization")
    fig.update_traces(texttemplate='%{label}<br> %{value}', textfont_size=12)
    st.plotly_chart(fig, use_container_width=True)
def count_appointments(patient_data):
    return len(patient_data['appointmentdate'].unique())


def show_patient_dash(merged_table):
    
    
    # Convert the merged_table to a DataFrame if it's not already one
    
    if not isinstance(merged_table, pd.DataFrame):
        merged_table = pd.DataFrame(merged_table)
    
    # Create a container in the sidebar for patient information
    with st.sidebar:
        st.subheader("Patient Information")
        entered_patient_id = st.text_input("Enter Patient ID")
        
        if entered_patient_id:
            try:
                entered_patient_id = int(entered_patient_id)
                patient_data = merged_table[merged_table['patientid'] == entered_patient_id]
                
                if not patient_data.empty:
                    patient_info = patient_data.iloc[0]
                    
                    # Create a container for patient information
                    with st.container():
                        st.markdown("---")  # Add a separator line
                        st.markdown("*Patient Details*")
                        
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write("*PatientID:*")
                            st.write("*Name:*")
                            st.write("*DOB:*")
                            st.write("*Age:*")
                            st.write("*Gender:*")
                        with col2:
                            st.write(f"{entered_patient_id}")
                            st.write(f"{patient_info['firstname']} {patient_info['lastname']}")
                            st.write(f"{patient_info['dob']}")
                            st.write(f"{patient_info['age']}")
                            st.write(f"{patient_info['gender']}")
                        
                        st.write("*City:*", patient_info['city'])
                        st.write("*Email:*", patient_info['email'])
                        st.write("*Contact:*", patient_info['contactnumber'])
                        st.write("*Address:*", patient_info['address'])
                        
                        st.markdown("---")  # Add a separator line
                else:
                    st.warning("No data found for the entered Patient ID.")
            except ValueError:
                st.error("Invalid Patient ID. Please enter a valid number.")
    
    if entered_patient_id and not merged_table[merged_table['patientid'] == entered_patient_id].empty:
        patient_data = merged_table[merged_table['patientid'] == entered_patient_id]
      
        
        appointment_count = count_appointments(patient_data)
    
        st.subheader(f"Total No of Visits :{appointment_count}")
        
    
        def determine_patient_type(patient_data, patient_id):
            # Filter data for the specific patient
            patient_history = patient_data[patient_data['patientid'] == patient_id]
            
            # Check if the patient has ever been an inpatient
            if 'Inpatient' in patient_history['patient_type'].values:
                return 'INPATIENT'
            else:
                return 'OUTPATIENT'

        # Assuming 'entered_patient_id' is the ID of the currently displayed patient
        patient_type = determine_patient_type(merged_table, entered_patient_id)

        # Set button color based on patient type
        button_color = "red" if patient_type == "INPATIENT" else "green"

        button_style = f"""
            <style>
            .patient-type-button {{
                background-color: {button_color};
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                font-size: 16px;
                font-weight: bold;
                text-align: center;
                display: inline-block;
                margin: 10px 0;
            }}
            </style>
        """

        st.markdown(button_style, unsafe_allow_html=True)
        st.markdown(f'<div class="patient-type-button">{patient_type}</div>', unsafe_allow_html=True)


######################################################################################################################################################
        st.title("Medical Data")
        st.markdown("##### (This below indications denotes comparision of last two dates)")

            
        st.markdown("""
<style>
.arrow-up { color: green; }
.arrow-down { color: red; }
.improved { color: green; }
.not-improved { color: red; }
</style>
""", unsafe_allow_html=True)
        
        # Function to compare Snellen values and determine improvement
        def compare_snellen(current, previous):
            if pd.isna(current) or pd.isna(previous):
                return ""
            
            def snellen_to_numeric(snellen):
                try:
                    numerator, denominator = map(int, snellen.split('/'))
                    return numerator / denominator
                except:
                    return None

            current_numeric = snellen_to_numeric(current)
            previous_numeric = snellen_to_numeric(previous)

            if current_numeric is None or previous_numeric is None:
                return ""
            
            if current_numeric > previous_numeric:
                return ' <span class="improved">(improved)</span>'
            elif current_numeric < previous_numeric:
                return ' <span class="not-improved">(not improved)</span>'
            else:
                return " (no change)"
            
            
                # Function to determine arrow direction
        def get_arrow(current, previous, metric):
            if pd.isna(current) or pd.isna(previous):
                return ""
            if metric in ['Vision', 'Lens Opacity']:
                return ""  # These are categorical, so we don't compare them
            elif metric in ['IOP', 'Blood Pressure']:
                try:
                    return '<span class="arrow-down">↓</span>' if float(current) < float(previous) else '<span class="arrow-up">↑</span>'
                except ValueError:
                    return ""  # Return empty string if conversion fails
            else:
                try:
                    return '<span class="arrow-up">↑</span>' if float(current) > float(previous) else '<span class="arrow-down">↓</span>'
                except ValueError:
                    return ""  # Return empty string if conversion fails


       # Select the columns we want to display in the desired order
        detailed_data = patient_data[[
    'diagnosisdate', 
    'righteye_snellenchartresult', 'lefteye_snellenchartresult',
    'righteye_iop', 'lefteye_iop',
    'blood_pressure','treatmentname', 'treatment_description' ,
    'medications', 'nextvisitdate', 'scanstobetaken'
]]

            # Remove duplicate rows and sort
        detailed_data_unique = detailed_data.drop_duplicates()
        detailed_data_sorted = detailed_data_unique.sort_values('diagnosisdate', ascending=False)

        # Format date columns
        date_columns = ['diagnosisdate', 'nextvisitdate']
        for col in date_columns:
            detailed_data_sorted[col] = pd.to_datetime(detailed_data_sorted[col]).dt.strftime('%B %d, %Y')

        # Calculate improvement status for Snellen chart results
        if len(detailed_data_sorted) >= 2:
            re_snellen_improvement = compare_snellen(detailed_data_sorted['righteye_snellenchartresult'].iloc[0], 
                                                    detailed_data_sorted['righteye_snellenchartresult'].iloc[1])
            le_snellen_improvement = compare_snellen(detailed_data_sorted['lefteye_snellenchartresult'].iloc[0], 
                                                    detailed_data_sorted['lefteye_snellenchartresult'].iloc[1])
        else:
            re_snellen_improvement = ""
            le_snellen_improvement = ""

                # Calculate arrows for each metric
        arrows = {}
        numeric_columns = ['righteye_iop', 'lefteye_iop', 'blood_pressure']
        for col in numeric_columns:
            if len(detailed_data_sorted[col]) >= 2:
                arrows[col] = get_arrow(detailed_data_sorted[col].iloc[0], detailed_data_sorted[col].iloc[1], col.split('_')[-1])
            else:
                arrows[col] = ""

        # Rename columns for better readability and add arrows
        column_rename = {
    'diagnosisdate': 'Diagnosis Date',
    'righteye_snellenchartresult': f'RE VISION{re_snellen_improvement}',
    'lefteye_snellenchartresult': f'LE VISION{le_snellen_improvement}',
    'righteye_iop': f'RE IOP {arrows.get("righteye_iop", "")}',
    'lefteye_iop': f'LE IOP {arrows.get("lefteye_iop", "")}',
    'blood_pressure': f'Blood Pressure {arrows.get("blood_pressure", "")}',
    'medications': 'Medications',
    'nextvisitdate': 'Next Visit',
    'scanstobetaken': 'Scans to be Taken',
    'treatmentname': 'Treatment Name',  # Add this line
    'treatment_description': 'Treatment Description'  # Add this line
}
        detailed_data_sorted = detailed_data_sorted.rename(columns=column_rename)


        # Transpose the dataframe
        transposed_data = detailed_data_sorted.T

        # Use the 'Diagnosis Date' row as the new column headers
        transposed_data.columns = transposed_data.loc['Diagnosis Date']

        # Remove the 'Diagnosis Date' row as it's now the header
        transposed_data = transposed_data.drop('Diagnosis Date')

              
        html = transposed_data.to_html(classes='dataframe', escape=False)

        # Add custom CSS for auto-fitting columns, rows, and improving readability
        st.markdown("""
        <style>
        .table-container {
            overflow-x: auto;
            max-width: 100%;
        }
        table.dataframe {
            width: 100%;
            table-layout: auto;
            border-collapse: collapse;
        }
        table.dataframe th, table.dataframe td {
            min-width: 100px;
            max-width: 200px;
            padding: 8px;
            border: 1px solid #ddd;
            word-wrap: break-word;
            overflow-wrap: break-word;
            vertical-align: top;
        }
        table.dataframe th {
            background-color: #f2f2f2;
            font-weight: bold;
            white-space: normal;
            height: auto;
        }
        table.dataframe td {
            white-space: normal;
            height: auto;
        }
        table.dataframe tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        </style>
        """, unsafe_allow_html=True)

        
        st.markdown('<div class="table-container">', unsafe_allow_html=True)
        st.write(html, unsafe_allow_html=True)
        st.markdown('</div>', unsafe_allow_html=True)
             
    # Add this new section for line charts

    # Convert diagnosisdate to datetime
    patient_data['diagnosisdate'] = pd.to_datetime(patient_data['diagnosisdate'])

    # Sort the data by date
    patient_data_sorted = patient_data.sort_values('diagnosisdate')

    

     # Function to create a bar chart
    def create_interactive_bar_chart(data, x_column, y_column, title):
        fig = go.Figure()

        if 'snellen' in y_column.lower():
            def snellen_to_numeric(snellen):
                try:
                    numerator, denominator = map(int, snellen.split('/'))
                    return denominator  # Use the denominator for sorting and plotting
                except ValueError:
                    return None  

            y_values = [snellen_to_numeric(value) for value in data[y_column]]

            # Filter out None values
            filtered_data = data[[y_column, x_column]].copy()
            filtered_data['Numeric Vision'] = y_values
            filtered_data = filtered_data.dropna(subset=['Numeric Vision'])

            if filtered_data.empty:
                raise ValueError("No valid Snellen values found for plotting.")

            # Sort the values for proper tick positioning
            sorted_numeric_vision = sorted(filtered_data['Numeric Vision'].unique())
            sorted_snellen_values = sorted(filtered_data[y_column].unique(), key=lambda x: snellen_to_numeric(x))

            fig.add_trace(go.Scatter(
                x=filtered_data[x_column],
                y=filtered_data['Numeric Vision'],
                mode='markers+text',
                text=filtered_data[y_column],
                textposition='top center',
                name=title,
                marker=dict(size=10, line=dict(width=2, color='blue'))
            ))

            fig.add_trace(go.Scatter(
                x=filtered_data[x_column],
                y=filtered_data['Numeric Vision'],
                mode='lines',
                name=f'{title} Line',
                line=dict(color='blue', width=2),
                showlegend=False
            ))

            fig.update_layout(
                title=title,
                xaxis_title='Date',
                yaxis=dict(
                    tickmode='array',
                    tickvals=sorted_numeric_vision,
                    ticktext=sorted_snellen_values,
                    title='Vision (Snellen Denominator)'
                ),
                height=400, width=600
            )

            return fig
    
    
    
    def create_interactive_line_chart(data, x_column, y_columns, title):
        fig = go.Figure()
        colors = {'RE': 'orange', 'LE': 'blue'}  
        for y_column, name in y_columns:
            color = colors.get(name.split()[0], 'gray')  # Default to gray if not RE or LE
            fig.add_trace(go.Scatter(x=data[x_column], y=data[y_column], mode='lines+markers', name=name, line=dict(color=color)))
        fig.update_layout(
            title=title,
            xaxis_title='Date',
            yaxis_title=title,
            height=400,
            width=600,
            margin=dict(l=50, r=50, t=50, b=50)
        )
        return fig


    metrics = [
        ('righteye_snellenchartresult', 'RE VISION', 'bar'),
        ('lefteye_snellenchartresult', 'LE VISION', 'bar'),
        ([('righteye_iop', 'RE IOP'), ('lefteye_iop', 'LE IOP')], 'IOP', 'line'),
        ('blood_pressure', 'Blood Pressure', 'line')
    ]

    
    # Layout for the dashboard
    st.title("Patient Eye Health Dashboard")

    st.subheader("Vision")  
    col1, col2 = st.columns(2)

    st.subheader("IOP and Blood Pressure")
    col3, col4 = st.columns(2)

    columns = [col2, col1, col3, col4]

    for i, (metric, title, chart_type) in enumerate(metrics):
        if chart_type == 'bar':
            chart = create_interactive_bar_chart(patient_data_sorted, 'diagnosisdate', metric, title)
        else:
            if isinstance(metric, list):  # For IOP chart with two lines
                chart = create_interactive_line_chart(patient_data_sorted, 'diagnosisdate', metric, title)
            else:
                chart = create_interactive_line_chart(patient_data_sorted, 'diagnosisdate', [(metric, title)], title)
        
        with columns[i]:
            st.plotly_chart(chart, use_container_width=True)




#############################################################################################################################################################################################################################
        
        
        
        
        
        
        
        # Check if the patient is an inpatient
        is_inpatient = patient_data['patient_type'].iloc[-1].lower() == 'inpatient'        
    if is_inpatient:        
        st.subheader("Pre-op and Post-op Comparison")

    # Select pre-op and post-op columns
    pre_post_data = patient_data[[
    'diagnosisdate',
    'operatedeye',  # This is the correct column name
    'righteye_snellenchartresult', 'righteye_iop', 'righteye_lensopacity', 'righteye_pupilreactiontime',
    'lefteye_snellenchartresult', 'lefteye_iop', 'lefteye_lensopacity', 'lefteye_pupilreactiontime',
    'postop_righteye_snellenchartresult', 'postop_righteye_iop', 'postop_righteye_lensopacity', 'postop_righteye_pupilreactiontime',
    'postop_lefteye_snellenchartresult', 'postop_lefteye_iop', 'postop_lefteye_lensopacity', 'postop_lefteye_pupilreactiontime',
    'blood_pressure', 'postop_blood_pressure', 'treatmentname', 'treatment_description'
]]
    # Remove duplicate rows and sort
    pre_post_data_unique = pre_post_data.drop_duplicates()
    pre_post_data_sorted = pre_post_data_unique.sort_values('diagnosisdate', ascending=False)

    # Format date column
    pre_post_data_sorted['diagnosisdate'] = pd.to_datetime(pre_post_data_sorted['diagnosisdate']).dt.strftime('%B %d, %Y')

    st.markdown("""
    <style>
    .dataframe-comparison {
        width: 100%;
        table-layout: auto;
    }
    .dataframe-comparison th, .dataframe-comparison td {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        padding: 8px;
        border: 1px solid #ddd;
    }
    .dataframe-comparison th {
        background-color: #f2f2f2;
        font-weight: bold;
    }
    .dataframe-comparison tr:nth-child(even) {
        background-color: #f9f9f9;
    }
    </style>
    """, unsafe_allow_html=True)

    def get_arrow(current, previous, metric):
        if pd.isna(current) or pd.isna(previous):
            return ""
        if metric in ['Vision', 'Lens Opacity']:
            return ""  # These are categorical, so we don't compare them
        elif metric in ['IOP', 'Blood Pressure', 'Pupil Reaction']:
            try:
                current_float = float(current)
                previous_float = float(previous)
                if current_float < previous_float:
                    return '<span style="color: red;">↓</span>'
                elif current_float > previous_float:
                    return '<span style="color: green;">↑</span>'
                else:
                    return ' '
            except ValueError:
                return ""  # Return empty string if conversion fails
        else:
            return ""  # For any other metrics, don't show an arrow
    def compare_snellen(current, previous):
        if pd.isna(current) or pd.isna(previous):
            return ""
        
        def snellen_to_numeric(snellen):
            try:
                numerator, denominator = map(int, snellen.split('/'))
                return numerator / denominator
            except:
                return None

        current_numeric = snellen_to_numeric(current)
        previous_numeric = snellen_to_numeric(previous)

        if current_numeric is None or previous_numeric is None:
            return ""
        
        if current_numeric > previous_numeric:
            return ' <span style="color: green;">(improved)</span>'
        elif current_numeric < previous_numeric:
            return ' <span style="color: red;">(not improved)</span>'
        else:
            return ' <span style="color: orange;">(no change)</span>'
    
    metrics = [
        'RE Vision', 'LE Vision',
        'RE IOP', 'LE IOP',
        'RE Lens Opacity', 'LE Lens Opacity',
        'RE Pupil Reaction', 'LE Pupil Reaction',
        'Blood Pressure'
    ]
    st.markdown("<h2 style='text-align: center; border-bottom: 2px solid #ccc;'>Pre-op and Post-op Comparison</h2>", unsafe_allow_html=True)

    # Add this function at the beginning of your script
    def get_button_color(eye_value):
        if eye_value == 'LEFT EYE':
            return '#4F8BF9'  # Blue
        elif eye_value == 'RIGHT EYE':
            return '#FFA500'  # Orange
        else:
            return '#8A2BE2'  # Purple


    st.markdown("""
<style>
.inpatient-container {
    display: flex;
    align-items: stretch;
    background-color: #ffe6f9;
    padding: 20px;
    border-radius: 10px;
    margin-bottom: 20px;
    border: 2px solid #ffb3e6;
}
.text-container {
    flex: 2;
    background-color: white;
    padding: 10px;
    border-radius: 5px;
    margin: 0 20px;
}
.image-container {
    flex: 0.4;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: white;
    border-radius: 5px;
    padding: 2px;
    border: 2px solid #4CAF50;
    box-shadow: 0 0 10px rgba(76, 175, 80, 0.5);
    width: 150px;
    height: 150px;
    overflow: hidden;
}

.image-container img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.image-container.left {
    order: -1;
}
.image-container.right {
    order: 1;
}
.date {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 10px;
}
.info {
    margin: 5px 0;
    font-size: 14px;
}
</style>
""", unsafe_allow_html=True)
    
    for _, row in pre_post_data_sorted.iterrows():
        if not row[['postop_righteye_snellenchartresult', 'postop_righteye_iop', 'postop_righteye_lensopacity', 'postop_righteye_pupilreactiontime',
                    'postop_lefteye_snellenchartresult', 'postop_lefteye_iop', 'postop_lefteye_lensopacity', 'postop_lefteye_pupilreactiontime']].isnull().all():
            
            date = row['diagnosisdate']
            operated_eye = row['operatedeye'] if pd.notna(row['operatedeye']) else "N/A"
            treatment = row['treatmentname'] if pd.notna(row['treatmentname']) else "N/A"
            description = row['treatment_description'] if pd.notna(row['treatment_description']) else "N/A"

            left_image_path = r"E:\AUROITECH INTERN\right eye.jpg"
            right_image_path = r"E:\AUROITECH INTERN\left eye.jpg"

            # Function to get base64 encoded image
            def get_image_base64(image_path):
                if image_path and os.path.exists(image_path):
                    with open(image_path, "rb") as img_file:
                        return base64.b64encode(img_file.read()).decode()
                return None

            # Get base64 encoded images
            left_img_base64 = get_image_base64(left_image_path)
            right_img_base64 = get_image_base64(right_image_path)

            # Determine which eye(s) to display
            if operated_eye.upper() == "LEFT EYE":
                left_display = "flex"
                right_display = "none"
            elif operated_eye.upper() == "RIGHT EYE":
                left_display = "none"
                right_display = "flex"
            else:  # Both eyes or any other case
                left_display = "flex"
                right_display = "flex"

            # Create the HTML layout
            st.markdown(f"""
            <div class="inpatient-container">
                <div class="image-container left" style="display: {left_display};">
    {f'<img src="data:image/jpeg;base64,{left_img_base64}" alt="Left Eye">' if left_img_base64 else 'Left Eye (No image)'}
</div>
                <div class="text-container">
                    <div class="date">Date: {date}</div>
                    <div class="info"><strong>Operated Eye:</strong> {operated_eye}</div>
                    <div class="info"><strong>Treatment:</strong> {treatment}</div>
                    <div class="info"><strong>Description:</strong> {description}</div>
                </div>
                <div class="image-container right" style="display: {right_display};">
    {f'<img src="data:image/jpeg;base64,{right_img_base64}" alt="Right Eye">' if right_img_base64 else 'Right Eye (No image)'}
</div>

            
            """, unsafe_allow_html=True)

        
            comparison_data = {
                'Medical Data': [],
                'Pre-op': [], 
                'Post-op': []  
            }

            for metric in metrics:
                if metric == 'RE Vision':
                    post_op = row['postop_righteye_snellenchartresult']
                    pre_op = row['righteye_snellenchartresult']
                    improvement = compare_snellen(post_op, pre_op)
                    comparison_data['Medical Data'].append(f"{metric}{improvement}")
                elif metric == 'LE Vision':
                    post_op = row['postop_lefteye_snellenchartresult']
                    pre_op = row['lefteye_snellenchartresult']
                    improvement = compare_snellen(post_op, pre_op)
                    comparison_data['Medical Data'].append(f"{metric}{improvement}")
                elif metric == 'RE IOP':
                    post_op = row['postop_righteye_iop']
                    pre_op = row['righteye_iop']
                    arrow = get_arrow(post_op, pre_op, 'IOP')
                    comparison_data['Medical Data'].append(f"{metric} {arrow}")
                elif metric == 'LE IOP':
                    post_op = row['postop_lefteye_iop']
                    pre_op = row['lefteye_iop']
                    arrow = get_arrow(post_op, pre_op, 'IOP')
                    comparison_data['Medical Data'].append(f"{metric} {arrow}")
                elif metric == 'RE Lens Opacity':
                    post_op = row['postop_righteye_lensopacity']
                    pre_op = row['righteye_lensopacity']
                    comparison_data['Medical Data'].append(metric)
                elif metric == 'LE Lens Opacity':
                    post_op = row['postop_lefteye_lensopacity']
                    pre_op = row['lefteye_lensopacity']
                    comparison_data['Medical Data'].append(metric)
                elif metric == 'RE Pupil Reaction':
                    post_op = row['postop_righteye_pupilreactiontime']
                    pre_op = row['righteye_pupilreactiontime']
                    arrow = get_arrow(post_op, pre_op, 'Pupil Reaction')
                    comparison_data['Medical Data'].append(f"{metric} {arrow}")
                elif metric == 'LE Pupil Reaction':
                    post_op = row['postop_lefteye_pupilreactiontime']
                    pre_op = row['lefteye_pupilreactiontime']
                    arrow = get_arrow(post_op, pre_op, 'Pupil Reaction')
                    comparison_data['Medical Data'].append(f"{metric} {arrow}")
                elif metric == 'Blood Pressure':
                    post_op = row['postop_blood_pressure']
                    pre_op = row['blood_pressure']
                    arrow = get_arrow(post_op, pre_op, 'Blood Pressure')
                    comparison_data['Medical Data'].append(f"{metric} {arrow}")
                
                comparison_data['Pre-op'].append(pre_op)  
                comparison_data['Post-op'].append(post_op)  
                comparison_df = pd.DataFrame(comparison_data)
            

            st.write(comparison_df.to_html(classes='dataframe-comparison', escape=False, index=False), unsafe_allow_html=True)
            
            st.markdown("---")
            
    #################################################################################################################################

    
    # Main function
def main():
    if st.session_state.mode == "Table":
        conn = get_db_connection()
        relationships = get_table_relationships(conn)
        primary_keys = get_primary_keys(conn)
        related_tables = find_related_tables('patients', relationships)

        if not related_tables:
            st.warning("No related tables found for 'patients'. Check your database schema or relationships.")
            conn.close()
            return

        tables = {table_name: get_table_data(conn, table_name) for table_name in related_tables}
        if 'patients' in tables:
            tables['patients'] = enhance_patient_data(tables['patients'])
        else:
            st.error("Patients table is missing. Cannot enhance patient data.")

        merged_table, merge_order = merge_tables(tables, relationships)
        merged_table  = trim_whitespace(merged_table)

        st.write(merged_table)

        if merged_table is None or merged_table.empty:
            st.error("Failed to merge tables or merged table is empty.")
            conn.close()
            return

        st.sidebar.header("Select Data")
        selected_columns = []

        for table_name in merge_order:
            columns = tables[table_name].columns.tolist()
            if columns:
                filtered_columns = filter_foreign_keys(columns, table_name, relationships, primary_keys)
                if filtered_columns:
                    st.sidebar.subheader(f"{table_name} Details")
                    selected_columns.extend(st.sidebar.multiselect(f"Columns from {table_name}", filtered_columns))

        st.sidebar.header("Filters")

        filters = {}

        categorical_columns = ['gender', 'unit', 'city', 'status', 'treatmentname', 'departmentname']  # Specify your categorical columns here
        for column in categorical_columns:
            if column in merged_table.columns:
                filter_options = st.sidebar.multiselect(f"Select values for {column}", merged_table[column].dropna().unique())
                if filter_options:
                    filters[column] = filter_options

        if st.sidebar.button("Display Selected Columns"):
            if not selected_columns:
                st.sidebar.warning("Please select at least one column.")
            else:
                filtered_table = merged_table.copy()
                if filters:
                    filtered_table = apply_filters(filtered_table, filters, categorical_columns)
                
                filtered_table_no_duplicates = filtered_table[selected_columns].drop_duplicates()
        
                st.write("Merged Table based on selected columns and filters (duplicates removed):")
                st.write(filtered_table_no_duplicates)

        st.session_state.merged_table = merged_table

        conn.close()

    elif st.session_state.mode == "Visualization":
        if 'merged_table' in st.session_state and st.session_state.merged_table is not None:
            show_visualizations(st.session_state.merged_table)
        else:
            st.error("No data available for visualization. Please go to Table Mode and load the data first.")
            
    
    elif st.session_state.mode == "Patients":
        if 'merged_table' in st.session_state and st.session_state.merged_table is not None:
            show_patient_dash(st.session_state.merged_table)
        else:
            st.error("No data available for visualization. Please go to Table Mode and load the data first") 

if __name__ == "__main__":
    main()