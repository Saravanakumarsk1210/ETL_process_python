# ETL Process with Python

This repository contains the code and resources needed to set up a hospital database and run a Streamlit application to visualize patient data.

## Setup Instructions

### 1. Download Files
Download `app.py`, the SQL file, and images into a single directory.

### 2. Set Up Database
1. Create a new database in PostgreSQL.
2. Copy the queries from the SQL file and execute them to set up the database tables.

### 3. Update `app.py`
1. Change the database connection parameters in `app.py` (around line 36):
   
    ```python
    def get_db_connection():
        conn = psycopg2.connect(
            dbname="your_db_name",
            user="your_user_name",
            password="your_password",
            host="localhost",
            port="5432"
        )
    ```

3. Change the path of the images to your current path in `app.py` (around lines 1021 and 1022):
    ```python
    left_image_path = r"your_path/left_image.jpg"
    right_image_path = r"your_path/right_image.jpg"
    ```

### 4. Run the Application
1. Open a command prompt or terminal.
2. Navigate to your project directory.
3. Run the following command to start the Streamlit application
   
    ```bash
    streamlit run app.py
    ```

## Additional Information

- Make sure you have the required Python packages installed. Download the requirements.txt 
    
    1. Open a command prompt or terminal.
    2. Navigate to your project directory.
    3. Run the following command to install them
       
   
    ```bash
      pip install -r requirements.txt
    ```

## Contact
For any questions or issues, please feel free to reach out.

---

Happy coding!
