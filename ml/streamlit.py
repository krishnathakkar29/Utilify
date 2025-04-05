import streamlit as st
import pandas as pd
import os
import io
import tempfile
import base64

def main():
    st.set_page_config(page_title="File Converter", page_icon="📊")
    
    st.title("Excel and CSV Converter")
    
    # Create tabs for the two conversion options
    tab1, tab2 = st.tabs(["Excel to CSV", "CSV to Excel"])
    
    with tab1:
        st.header("Excel to CSV Converter")
        
        # File upload
        excel_file = st.file_uploader("Upload an Excel file", type=["xlsx", "xls"], key="excel_uploader")
        
        if excel_file is not None:
            # Display file info
            file_details = {"Filename": excel_file.name, "FileType": excel_file.type, "FileSize": f"{excel_file.size / 1024:.2f} KB"}
            st.write(file_details)
            
            try:
                # Read the Excel file
                df = pd.read_excel(excel_file, engine='openpyxl')
                
                # Display preview
                st.subheader("Data Preview")
                st.dataframe(df.head())
                
                # Convert to CSV
                csv_data = df.to_csv(index=False).encode('utf-8')
                
                # Create download button
                csv_filename = os.path.splitext(excel_file.name)[0] + '.csv'
                
                st.download_button(
                    label="Download CSV",
                    data=csv_data,
                    file_name=csv_filename,
                    mime='text/csv',
                )
                
                st.success(f"Ready to download as {csv_filename}")
                
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    with tab2:
        st.header("CSV to Excel Converter")
        
        # File upload
        csv_file = st.file_uploader("Upload a CSV file", type=["csv"], key="csv_uploader")
        
        if csv_file is not None:
            # Display file info
            file_details = {"Filename": csv_file.name, "FileType": csv_file.type, "FileSize": f"{csv_file.size / 1024:.2f} KB"}
            st.write(file_details)
            
            try:
                # Read the CSV file
                df = pd.read_csv(csv_file)
                
                # Display preview
                st.subheader("Data Preview")
                st.dataframe(df.head())
                
                # Convert to Excel
                excel_buffer = io.BytesIO()
                with pd.ExcelWriter(excel_buffer, engine='openpyxl') as writer:
                    df.to_excel(writer, index=False, sheet_name='Sheet1')
                
                excel_data = excel_buffer.getvalue()
                
                # Create download button
                excel_filename = os.path.splitext(csv_file.name)[0] + '.xlsx'
                
                st.download_button(
                    label="Download Excel",
                    data=excel_data,
                    file_name=excel_filename,
                    mime='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                )
                
                st.success(f"Ready to download as {excel_filename}")
                
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    # Footer
    st.divider()
    st.caption("File Converter App - Convert between Excel and CSV formats easily.")

if __name__ == "__main__":
    main()