import streamlit as st
import pandas as pd
import requests
import os
import io
from PIL import Image
import streamlit as st
import requests
from PIL import Image
import io
import base64
def main():
    st.set_page_config(page_title="File Tools", page_icon="📄")
    
    st.title("File Tools")
    
    # Create tabs for different operations
    tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs(["Merge PDFs", "Split PDF", "Rotate PDF", "Convert Image", "Excel/CSV","Color Palette Extractor"])
    
    # Base URL for the API
    BASE_URL = "http://localhost:5000"  # Adjust as needed
    
    with tab1:
        st.header("Merge PDF Files")
        
        # File upload
        uploaded_files = st.file_uploader("Upload PDF files", type="pdf", accept_multiple_files=True, key="pdf_merger_uploader")
        
        if uploaded_files:
            # Display file info
            st.subheader("Files Selected")
            for file in uploaded_files:
                file_details = {"Filename": file.name, "FileSize": f"{file.size / 1024:.2f} KB"}
                st.write(file_details)
            
            if st.button("Merge PDFs", disabled=len(uploaded_files) < 2):
                if len(uploaded_files) >= 2:
                    try:
                        with st.spinner("Merging PDF files..."):
                            files = [('files', file) for file in uploaded_files]
                            response = requests.post(f"{BASE_URL}/merge", files=files)
                            
                            if response.status_code == 200:
                                st.download_button(
                                    label="Download Merged PDF",
                                    data=response.content,
                                    file_name="merged.pdf",
                                    mime="application/pdf",
                                )
                                st.success("Ready to download merged PDF")
                            else:
                                st.error(f"Error: {response.text}")
                    except Exception as e:
                        st.error(f"Error: {str(e)}")
                else:
                    st.warning("Please upload at least two PDF files.")
    
    with tab2:
        st.header("Split PDF")
        
        # File upload
        split_file = st.file_uploader("Upload a PDF file", type="pdf", key="pdf_splitter_uploader")
        
        if split_file is not None:
            # Display file info
            file_details = {"Filename": split_file.name, "FileSize": f"{split_file.size / 1024:.2f} KB"}
            st.write(file_details)
            
            try:
                # We could use PyPDF2 to get total pages, but that would require additional dependencies
                # Instead, we'll let users specify the range
                st.subheader("Specify Page Range")
                col1, col2 = st.columns(2)
                start_page = col1.number_input("Start Page", min_value=1, value=1, step=1)
                end_page = col2.number_input("End Page", min_value=start_page, value=start_page, step=1)
                
                if st.button("Split PDF"):
                    with st.spinner("Splitting PDF..."):
                        files = {'file': split_file}
                        data = {'start_page': start_page, 'end_page': end_page}
                        response = requests.post(f"{BASE_URL}/split", files=files, data=data)
                        
                        if response.status_code == 200:
                            st.download_button(
                                label="Download Split PDF",
                                data=response.content,
                                file_name="split.pdf",
                                mime="application/pdf",
                            )
                            st.success("Ready to download split PDF")
                        else:
                            st.error(f"Error: {response.text}")
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    with tab3:
        st.header("Rotate PDF")
        
        # File upload
        rotate_file = st.file_uploader("Upload a PDF file", type="pdf", key="pdf_rotator_uploader")
        
        if rotate_file is not None:
            # Display file info
            file_details = {"Filename": rotate_file.name, "FileSize": f"{rotate_file.size / 1024:.2f} KB"}
            st.write(file_details)
            
            try:
                st.subheader("Rotation Options")
                angle = st.select_slider(
                    "Select rotation angle",
                    options=[0, 90, 180, 270],
                    value=90,
                    format_func=lambda x: f"{x}°"
                )
                
                if st.button("Rotate PDF"):
                    with st.spinner("Rotating PDF..."):
                        files = {'file': rotate_file}
                        data = {'angle': angle}
                        response = requests.post(f"{BASE_URL}/rotate", files=files, data=data)
                        
                        if response.status_code == 200:
                            st.download_button(
                                label="Download Rotated PDF",
                                data=response.content,
                                file_name="rotated.pdf",
                                mime="application/pdf",
                            )
                            st.success("Ready to download rotated PDF")
                        else:
                            st.error(f"Error: {response.text}")
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    with tab4:
        st.header("Convert Image Format")
        
        # File upload
        image_file = st.file_uploader("Upload an image", type=["png", "jpg", "jpeg", "webp", "bmp", "gif", "tiff"], key="image_converter_uploader")
        
        if image_file is not None:
            # Display file info
            file_details = {"Filename": image_file.name, "FileType": image_file.type, "FileSize": f"{image_file.size / 1024:.2f} KB"}
            st.write(file_details)
            
            try:
                # Display the uploaded image
                image = Image.open(image_file)
                st.subheader("Image Preview")
                st.image(image, caption="Uploaded Image", use_column_width=True)
                
                # Format selection
                st.subheader("Conversion Options")
                target_format = st.selectbox(
                    "Select target format",
                    options=["jpeg", "png", "webp", "bmp", "gif", "tiff"],
                    index=0
                )
                
                if st.button("Convert Image"):
                    with st.spinner("Converting image..."):
                        # Reset file pointer to beginning
                        image_file.seek(0)
                        
                        files = {'image': image_file}
                        data = {'format': target_format}
                        response = requests.post(f"{BASE_URL}/convert_img", files=files, data=data)
                        
                        if response.status_code == 200:
                            st.download_button(
                                label=f"Download {target_format.upper()} Image",
                                data=response.content,
                                file_name=f"converted.{target_format}",
                                mime=f"image/{target_format if target_format != 'jpg' else 'jpeg'}",
                            )
                            st.success(f"Ready to download as {target_format.upper()} image")
                        else:
                            st.error(f"Error: {response.text}")
            except Exception as e:
                st.error(f"Error: {str(e)}")
    
    with tab5:
        st.header("Excel and CSV Converter")
        
        # Create tabs for the two conversion options
        excel_tab, csv_tab = st.tabs(["Excel to CSV", "CSV to Excel"])
        
        with excel_tab:
            st.subheader("Excel to CSV Converter")
            
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
        
        with csv_tab:
            st.subheader("CSV to Excel Converter")
            
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
    with tab6:
        st.title("🎨 Image Color Extractor")

        uploaded_file = st.file_uploader("Upload an image", type=["png", "jpg", "jpeg"])

        if uploaded_file is not None:
            st.image(uploaded_file, caption='Uploaded Image', use_column_width=True)
            
            # Call Flask API
            with st.spinner("Extracting colors..."):
                response = requests.post(
                    "https://sacrifice-ham-still-place.trycloudflare.com/extract-colors",
                    files={"image": uploaded_file.getvalue()}
                )

            if response.status_code == 200:
                data = response.json()

                st.subheader("Extracted Colors")
                for color in data["colors"]:
                    col1, col2 = st.columns([1, 5])
                    with col1:
                        st.markdown(
                            f"<div style='width: 30px; height: 30px; background-color:{color['hex']}; border-radius:5px;'></div>",
                            unsafe_allow_html=True
                        )
                    with col2:
                        st.write(f"RGB: {color['rgb']}, HEX: {color['hex']}, Pixels: {color['pixels']}")

                st.subheader("Color Palette")
                palette_img = Image.open(io.BytesIO(base64.b64decode(data["palette_image_base64"])))
                st.image(palette_img, caption="Color Palette", use_column_width=False)

            else:
                st.error("Failed to extract colors. Please check the server.")
    # Footer
    st.divider()
    st.caption("File Tools App - Convert, merge, split, and manipulate files easily.")

if __name__ == "__main__":
    main()