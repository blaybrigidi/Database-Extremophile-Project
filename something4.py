import streamlit as st
import mysql.connector
import pandas as pd
import plotly.express as px
import numpy as np

# Database connection function
def connect_to_db():
    return mysql.connector.connect(
        host="localhost",
        port=3306,
        user="root",
        password="password",
        database="ProjectDB"
    )

# Function to execute query and return results as a dataframe
def execute_query(query, params=None):
    conn = connect_to_db()
    cursor = conn.cursor()
    if params:
        # Convert numpy types to standard Python types
        params = tuple(int(p) if isinstance(p, np.integer) else p for p in params)
        cursor.execute(query, params)
    else:
        cursor.execute(query)
    result = cursor.fetchall()
    columns = [i[0] for i in cursor.description]
    df = pd.DataFrame(result, columns=columns)
    cursor.close()
    conn.close()
    return df

# Search functionality
def search_database(search_term):
    query = """
    SELECT 'Organism' as Type, Name as Result FROM Organism WHERE Name LIKE %s
    UNION
    SELECT 'Project' as Type, Title as Result FROM ProjectInfo WHERE Title LIKE %s
    """
    return execute_query(query, (f"%{search_term}%", f"%{search_term}%"))

# Organism profile page
def organism_profile(organism_name):
    organism_info = execute_query("SELECT * FROM Organism_Profile WHERE Name = %s", (organism_name,))
    organism_id = int(organism_info.iloc[0]['OrganismID'])
    environmental_conditions = execute_query("SELECT * FROM EnvironmentalCondition WHERE OrganismID = %s", (organism_id,))
    projects = execute_query("""
    SELECT pi.Title, pi.Description, pi.StartDate, pi.EndDate, ps.Status
    FROM ProjectInfo pi
    JOIN Organism_ResearchProject orp ON pi.ProjectID = orp.ProjectID
    JOIN ProjectStatus ps ON pi.ProjectID = ps.ProjectID
    JOIN Organism o ON orp.OrganismID = o.OrganismID
    WHERE o.Name = %s
    """, (organism_name,))

    st.subheader(f"Organism Profile: {organism_name}")
    st.write(organism_info)
    st.subheader("Environmental Conditions")
    st.write(environmental_conditions)
    st.subheader("Associated Projects")
    st.write(projects)

# Student View
def student_view():
    st.header("Student View")
    
    query = st.selectbox("Select a query:", [
        "List organisms with their taxonomic information and ecosystem",
        "Find average optimal temperature for organisms in each ecosystem"
    ])
    
    if query == "List organisms with their taxonomic information and ecosystem":
        domain_filter = st.multiselect("Filter by Domain:", ["Archaea", "Bacteria", "Eukarya"])
        
        base_query = "SELECT * FROM Student_Organism_Taxonomy_Ecosystem"
        if domain_filter:
            query = base_query + f" WHERE Domain IN ({','.join(['%s']*len(domain_filter))})"
            df = execute_query(query, tuple(domain_filter))
        else:
            df = execute_query(base_query)
        
        st.dataframe(df)
        
        # Visualization
        domain_counts = df['Domain'].value_counts()
        fig = px.bar(x=domain_counts.index, y=domain_counts.values, labels={'x': 'Domain', 'y': 'Count'}, title='Organism Count by Domain')
        st.plotly_chart(fig)
    
    elif query == "Find average optimal temperature for organisms in each ecosystem":
        df = execute_query("SELECT * FROM Student_Avg_Optimum_Temp_By_Ecosystem")
        st.dataframe(df)
        
        # Visualization
        fig = px.bar(df, x='EcosystemName', y='AverageOptimalTemp', title='Average Optimal Temperature by Ecosystem')
        st.plotly_chart(fig)

# Researcher View
def researcher_view():
    st.header("Researcher View")
    
    query = st.selectbox("Select a query:", [
        "Organisms with extreme temperature requirements",
        "Funding sources for projects related to aquatic ecosystems",
        "Analysis organisms and projects by domain and ecosystem",
        "Organism names, average optimum temperature, and associated project titles"
    ])
    
    if query == "Organisms with extreme temperature requirements":
        df = execute_query("SELECT * FROM Researcher_Extreme_Temperature_Organisms")
        st.dataframe(df)
    
    elif query == "Funding sources for projects related to aquatic ecosystems":
        df = execute_query("SELECT * FROM Researcher_Funding_Aquatic_Projects")
        st.dataframe(df)
    
    elif query == "Analysis organisms and projects by domain and ecosystem":
        df = execute_query("SELECT * FROM Researcher_Organisms_Projects_Domain_Ecosystem")
        st.dataframe(df)

    elif query == "Organism names, average optimum temperature, and associated project titles":
        df = execute_query("SELECT * FROM Researcher_Organism_Temperature_Project")
        st.dataframe(df)

# Administrator View
def administrator_view():
    st.header("Administrator View")
    
    query = st.selectbox("Select a query:", [
        "List all projects with their status and count of associated organisms",
        "Find organisms without any associated projects",
        "Calculate the duration of each project and list associated organisms",
        "View temperature statistics for specific ecosystems",
        "High-funded projects and associated organisms"
    ])
    
    if query == "List all projects with their status and count of associated organisms":
        df = execute_query("SELECT * FROM Admin_Projects_Status_OrganismCount")
        st.dataframe(df)
    
    elif query == "Find organisms without any associated projects":
        df = execute_query("SELECT * FROM Admin_Organisms_Without_Projects")
        st.dataframe(df)
    
    elif query == "Calculate the duration of each project and list associated organisms":
        df = execute_query("SELECT * FROM Admin_Project_Duration_Organisms")
        st.dataframe(df)
    
    elif query == "View temperature statistics for specific ecosystems":
        df = execute_query("SELECT * FROM Admin_Temperature_Stats_By_Ecosystem")
        st.dataframe(df)
    
    elif query == "High-funded projects and associated organisms":
        df = execute_query("SELECT * FROM Admin_High_Funded_Projects")
        st.dataframe(df)
        
        # Visualization
        project_summary = df.groupby('ProjectTitle').agg({
            'TotalFunding': 'first',
            'ProjectStatus': 'first',
            'OrganismName': 'count'
        }).reset_index()
        project_summary = project_summary.rename(columns={'OrganismName': 'OrganismCount'})
        
        fig = px.bar(project_summary, x='ProjectTitle', y='TotalFunding', 
                     hover_data=['OrganismCount', 'ProjectStatus'], 
                     title='High-Funded Projects (>$2 million)')
        st.plotly_chart(fig)
        
        # Additional information
        st.subheader("Project Details")
        for project in project_summary['ProjectTitle'].unique():
            with st.expander(f"Project: {project}"):
                project_data = df[df['ProjectTitle'] == project]
                st.write(f"Total Funding: ${project_data['TotalFunding'].iloc[0]:.2f} million")
                st.write(f"Status: {project_data['ProjectStatus'].iloc[0]}")
                st.write(f"Number of Organisms: {len(project_data)}")
                st.write("Associated Organisms:")
                for _, row in project_data.iterrows():
                    st.write(f"- {row['OrganismName']} ({row['Domain']}, {row['EcosystemName']})")

# Main app
def main():
    st.title("Biological Research Database")
    
    # Search functionality
    search_term = st.sidebar.text_input("Search for organisms or projects:")
    if search_term:
        search_results = search_database(search_term)
        st.sidebar.write(search_results)
    
    # Navigation
    page = st.sidebar.selectbox("Select a page:", ["Student View", "Researcher View", "Administrator View", "Organism Profiles"])
    
    if page == "Student View":
        student_view()
    elif page == "Researcher View":
        researcher_view()
    elif page == "Administrator View":
        administrator_view()
    elif page == "Organism Profiles":
        organism_name = st.selectbox("Select an organism:", execute_query("SELECT Name FROM Organism")['Name'].tolist())
        organism_profile(organism_name)

if __name__ == "__main__":
    main()
