from flask import Flask, request, send_file, jsonify
import pandas as pd
import os
import tempfile
from werkzeug.utils import secure_filename
from PIL import Image
import io
import os
from flask import Flask, request, jsonify, send_file, after_this_request,send_from_directory
import os
import PyPDF2
from pypdf import PdfWriter, PdfReader
from docx import Document
from flask_cors import CORS
from PIL import Image
import tempfile
from flask import Flask, request, jsonify, send_file
from PIL import Image, ImageDraw
import extcolors
import math
import io
import matplotlib.pyplot as plt
from matplotlib import gridspec
import base64
app = Flask(__name__)
CORS(app)
# Ensure temporary directory exists
UPLOAD_FOLDER = os.path.join(os.getcwd(), "temp_uploads")
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size
def ensure_uploads_dir():
    if not os.path.exists('uploads'):
        os.makedirs('uploads')

def mergePDF(pdf_list):
    merger = PdfWriter()
    for pdf in pdf_list:
        merger.append(pdf)
    output_path = tempfile.mktemp(suffix=".pdf")
    merger.write(output_path)
    merger.close()
    for i in pdf_list:
        print(i)
        os.remove(f'{i}')
    return output_path

def split_pdf(input_pdf, start_page, end_page):
    with open(input_pdf, 'rb') as input_file:
        reader = PyPDF2.PdfReader(input_file)
        writer = PyPDF2.PdfWriter()

        start_page = max(0, start_page - 1)
        end_page = min(len(reader.pages), end_page)

        for page_num in range(start_page, end_page):
            writer.add_page(reader.pages[page_num])
        output_path = tempfile.mktemp(suffix=".pdf")
        with open(output_path, 'wb') as output_file:
            writer.write(output_file)
    os.remove(input_pdf)
    return output_path

def pdfRotate(input_file, angle):
    reader = PdfReader(input_file)
    writer = PdfWriter()
    count = len(reader.pages)
    for i in range(count):
        writer.add_page(reader.pages[i])
        writer.pages[i].rotate(angle)

    output_path = tempfile.mktemp(suffix=".pdf")
    with open(output_path, "wb") as fp:
        writer.write(fp)
    os.remove(input_file)
    return output_path

def extract_text_from_pdf(pdf_file):
    reader = PdfReader(pdf_file)
    text = ""
    for page in reader.pages:
        text += page.extract_text() + "\n"
    os.remove(pdf_file)
    return text

def save_text_to_docx(text, docx_file):
    doc = Document()
    doc.add_paragraph(text)
    doc.save(docx_file)

def resize_image(input_path, output_path, target_width, target_height, max_size_kb=25):
    with Image.open(input_path) as img:
        original_width, original_height = img.size
        target_ratio = target_width / target_height
        original_ratio = original_width / original_height

        if target_ratio > original_ratio:
            # Target aspect ratio is wider than original
            new_height = int(target_width / original_ratio)
            img = img.resize((target_width, new_height), Image.Resampling.LANCZOS)
            crop_height = (new_height - target_height) // 2
            img = img.crop((0, crop_height, target_width, crop_height + target_height))
        else:
            # Target aspect ratio is taller than original
            new_width = int(target_height * original_ratio)
            img = img.resize((new_width, target_height), Image.Resampling.LANCZOS)
            crop_width = (new_width - target_width) // 2
            img = img.crop((crop_width, 0, crop_width + target_width, target_height))

        # Determine the format from the output file extension
        output_format = output_path.split('.')[-1].upper()
        if output_format == 'JPG':
            output_format = 'JPEG'
        quality = 95
        # Save the image with high quality settings initially
        if output_format in ['JPEG', 'JPG']:
            quality = 95
            img.save(output_path, format=output_format, quality=quality, optimize=True, progressive=True)
        else:
            img.save(output_path, format=output_format)
        
        file_size_kb = os.path.getsize(output_path) / 1024
        if file_size_kb > max_size_kb:
            quality -= 5
            while quality > 10:
                img.save(output_path, format=output_format, quality=quality, optimize=True, progressive=True)
                file_size_kb = os.path.getsize(output_path) / 1024
                if file_size_kb <= max_size_kb:
                    break
                quality -= 5
        
        print(f"Image resized and saved to {output_path} with size {file_size_kb:.2f} KB")
    os.remove(input_path)

@app.route('/',methods = ['POST'])
def home():
    return 'PyPDF-backend'

@app.route('/merge', methods=['POST'])
def merge():
    ensure_uploads_dir()
    files = request.files.getlist('files')
    file_paths = []
    for file in files:
        file_path = os.path.join('uploads', file.filename)
        file.save(file_path)
        file_paths.append(file_path)

    output_path = mergePDF(file_paths)

    @after_this_request
    def remove_files(response):
        try:
            os.remove(output_path)
            for file_path in file_paths:
                os.remove(file_path)
        except Exception as e:
            print(f"Error removing file: {e}")
        return response

    return send_file(output_path, as_attachment=True)
    
@app.route('/split', methods=['POST'])
def split():
    ensure_uploads_dir()
    file = request.files['file']
    start_page = int(request.form['start_page'])
    end_page = int(request.form['end_page'])

    file_path = os.path.join('uploads', file.filename)
    file.save(file_path)

    output_path = split_pdf(file_path, start_page, end_page)

    @after_this_request
    def remove_files(response):
        try:
            os.remove(output_path)
            os.remove(file_path)
        except Exception as e:
            print(f"Error removing file: {e}")
        return response

    return send_file(output_path, as_attachment=True)
#hello
@app.route('/rotate', methods=['POST'])
def rotate():
    ensure_uploads_dir()
    file = request.files['file']
    angle = int(request.form['angle'])

    file_path = os.path.join('uploads', file.filename)
    file.save(file_path)

    output_path = pdfRotate(file_path, angle)

    @after_this_request
    def remove_files(response):
        try:
            os.remove(output_path)
            os.remove(file_path)
        except Exception as e:
            print(f"Error removing file: {e}")
        return response

    return send_file(output_path, as_attachment=True)

@app.route('/convert_img', methods=['POST'])
def convert_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file uploaded'}), 400
    if 'format' not in request.form:
        return jsonify({'error': 'Target format not specified'}), 400

    file = request.files['image']
    target_format = request.form['format'].lower()

    # Validate format
    valid_formats = ['jpeg', 'jpg', 'png', 'webp', 'bmp', 'gif', 'tiff']
    if target_format not in valid_formats:
        return jsonify({'error': f'Unsupported format: {target_format}'}), 400

    try:
        # Open the image
        img = Image.open(file.stream).convert("RGB")  # Convert to RGB to avoid mode issues

        # Prepare in-memory file
        img_io = io.BytesIO()
        img.save(img_io, target_format.upper())
        img_io.seek(0)

        # Determine MIME type
        mime_type = f'image/{target_format if target_format != "jpg" else "jpeg"}'

        return send_file(img_io, mimetype=mime_type, as_attachment=True,
                         download_name=f'converted.{target_format}')
    except Exception as e:
        return jsonify({'error': str(e)}), 500
def extract_colors(img):
    tolerance = 32
    limit = 24
    colors, pixel_count = extcolors.extract_from_image(img, tolerance, limit)
    return colors

def render_color_platte(colors):
    size = 100
    columns = 6
    width = int(min(len(colors), columns) * size)
    height = int((math.floor(len(colors) / columns) + 1) * size)
    result = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    canvas = ImageDraw.Draw(result)
    for idx, color in enumerate(colors):
        x = int((idx % columns) * size)
        y = int(math.floor(idx / columns) * size)
        canvas.rectangle([(x, y), (x + size - 1, y + size - 1)], fill=color[0])
    return result

def overlay_palette(img, color_palette):
    f = plt.figure(figsize=(10, 8), facecolor='None', edgecolor='k', dpi=100)
    gs = gridspec.GridSpec(2, 1, wspace=0.0, hspace=0.0)
    ax1 = f.add_subplot(gs[0])
    ax1.imshow(img)
    ax1.axis('off')
    ax2 = f.add_subplot(gs[1])
    ax2.imshow(color_palette)
    ax2.axis('off')
    plt.subplots_adjust(wspace=0, hspace=0, bottom=0)

    buf = io.BytesIO()
    plt.savefig(buf, format='PNG', bbox_inches='tight', pad_inches=0)
    buf.seek(0)
    plt.close(f)
    return buf

def rgb_to_hex(rgb_tuple):
    return '#{:02x}{:02x}{:02x}'.format(*rgb_tuple)

@app.route('/extract-colors', methods=['POST'])
def extract_colors_api():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    file = request.files['image']
    img = Image.open(file.stream).convert('RGB')
    print(img)
    colors = extract_colors(img)
    color_palette_img = render_color_platte(colors[:4])
    color_palette_data = io.BytesIO()
    color_palette_img.save(color_palette_data, format="PNG")
    color_palette_data.seek(0)
    palette_base64 = base64.b64encode(color_palette_data.read()).decode('utf-8')

    # Prepare color data with pixel count and hex
    hex_colors = [
        {
            'hex': rgb_to_hex(color[0]),
            'rgb': color[0],
            'pixels': color[1]
        }
        for color in colors
    ]

    return jsonify({
        'colors': hex_colors[:4],
        'palette_image_base64': palette_base64
    })
from flask import Flask, request, jsonify, send_file
import barcode
from barcode.writer import ImageWriter
import qrcode
import socket
import subprocess
import platform
import dns.resolver
import secrets
import string
import math
import os


def generate_secure_password(length=20, use_symbols=True):
    if length < 8:
        raise ValueError("Password length should be at least 8 characters for good security.")
    alphabet = string.ascii_letters + string.digits
    if use_symbols:
        alphabet += string.punctuation

    while True:
        password = ''.join(secrets.choice(alphabet) for _ in range(length))
        if (any(c.islower() for c in password) and
            any(c.isupper() for c in password) and
            any(c.isdigit() for c in password) and
            (not use_symbols or any(c in string.punctuation for c in password))):
            return password

def calculate_entropy(password):
    charset_size = 0
    if any(c.islower() for c in password):
        charset_size += 26
    if any(c.isupper() for c in password):
        charset_size += 26
    if any(c.isdigit() for c in password):
        charset_size += 10
    if any(c in string.punctuation for c in password):
        charset_size += len(string.punctuation)
    if any(c.isspace() for c in password):
        charset_size += 1

    entropy = len(password) * math.log2(charset_size) if charset_size else 0
    return entropy, charset_size

def estimate_crack_time(entropy):
    guesses_per_second = 1e10
    total_combinations = 2 ** entropy
    seconds = total_combinations / guesses_per_second
    return convert_time(seconds)

def convert_time(seconds):
    time_units = [
        ("years", 60 * 60 * 24 * 365),
        ("months", 60 * 60 * 24 * 30),
        ("days", 60 * 60 * 24),
        ("hours", 60 * 60),
        ("minutes", 60),
        ("seconds", 1),
    ]
    result = []
    for unit, duration in time_units:
        if seconds >= duration:
            value = int(seconds // duration)
            seconds %= duration
            result.append(f"{value} {unit}")
    return ', '.join(result) if result else "less than a second"

def password_strength_feedback(entropy):
    if entropy < 28:
        return "Very Weak 🔴"
    elif entropy < 36:
        return "Weak 🟠"
    elif entropy < 60:
        return "Reasonable 🟡"
    elif entropy < 80:
        return "Strong 🟢"
    else:
        return "Very Strong 🔵"

# ------------------- Routes -------------------

@app.route("/generate-password", methods=["POST"])
def api_generate_password():
    length = int(request.json.get("length", 20))
    use_symbols = request.json.get("symbols", "true").lower() == "true"
    try:
        password = generate_secure_password(length, use_symbols)
        return jsonify({"password": password})
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

@app.route("/check-password", methods=["POST"])
def api_check_password():
    data = request.json
    password = data.get("password", "")
    if not password:
        return jsonify({"error": "No password provided"}), 400

    entropy, charset = calculate_entropy(password)
    crack_time = estimate_crack_time(entropy)
    strength = password_strength_feedback(entropy)

    return jsonify({
        "password": password,
        "charset_size": charset,
        "entropy": round(entropy, 2),
        "crack_time": crack_time,
        "strength_feedback": strength
    })

@app.route("/ping", methods=["GET"])
def api_ping():
    host = request.args.get("host")
    if not host:
        return jsonify({"error": "No host provided"}), 400
    param = "-n" if platform.system().lower() == "windows" else "-c"
    try:
        output = subprocess.check_output(["ping", param, "4", host], stderr=subprocess.STDOUT, text=True)
        return jsonify({"result": output})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": e.output}), 500

@app.route("/dns-lookup", methods=["GET"])
def api_dns_lookup():
    domain = request.args.get("domain")
    if not domain:
        return jsonify({"error": "No domain provided"}), 400
    try:
        result = dns.resolver.resolve(domain, 'A')
        return jsonify({"dns_records": [ip.address for ip in result]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/ip-lookup", methods=["GET"])
def api_ip_lookup():
    domain = request.args.get("domain")
    if not domain:
        return jsonify({"error": "No domain provided"}), 400
    try:
        ip = socket.gethostbyname(domain)
        return jsonify({"ip": ip})
    except socket.gaierror as e:
        return jsonify({"error": str(e)}), 500

@app.route("/traceroute", methods=["GET"])
def api_traceroute():
    host = request.args.get("host")
    if not host:
        return jsonify({"error": "No host provided"}), 400
    traceroute_cmd = "tracert" if platform.system().lower() == "windows" else "traceroute"
    try:
        output = subprocess.check_output([traceroute_cmd, host], stderr=subprocess.STDOUT, text=True)
        return jsonify({"result": output})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": e.output}), 500

@app.route("/generate-barcode", methods=["POST"])
def api_generate_barcode():
    # Get text from form-data
    text = request.form.get("text", "sample")

    try:
        barcode_format = barcode.get_barcode_class('code128')
        barcode_obj = barcode_format(text, writer=ImageWriter())
        filename = "barcode_output"
        barcode_path = barcode_obj.save(filename)

        return send_file(f"{barcode_path}", mimetype='image/png')
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/generate-qrcode", methods=["POST"])
def api_generate_qrcode():
    # Get text from form-data
    text = request.form.get("text")
    if not text:
        return jsonify({"error": "No text provided"}), 400

    try:
        img = qrcode.make(text)
        qr_path = "qrcode.png"
        img.save(qr_path)

        return send_file(qr_path, mimetype='image/png')
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/excel-to-csv', methods=['POST'])
def excel_to_csv_endpoint():
    # Check if file is in the request
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file and file.filename.endswith(('.xlsx', '.xls')):
        # Save uploaded file temporarily
        filename = secure_filename(file.filename)
        excel_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(excel_path)
        
        # Create output path
        csv_filename = os.path.splitext(filename)[0] + '.csv'
        csv_path = os.path.join(app.config['UPLOAD_FOLDER'], csv_filename)
        
        try:
            # Convert Excel to CSV
            df = pd.read_excel(excel_path, engine='openpyxl')
            df.to_csv(csv_path, index=False)
            
            # Return the CSV file
            return send_file(
                csv_path,
                mimetype='text/csv',
                as_attachment=True,
                download_name=csv_filename
            )
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            # Clean up files
            if os.path.exists(excel_path):
                os.remove(excel_path)
            # Keep CSV file for a short time for download, it will be removed later
    else:
        return jsonify({"error": "File must be an Excel file (.xlsx or .xls)"}), 400

@app.route('/csv-to-excel', methods=['POST'])
def csv_to_excel_endpoint():
    # Check if file is in the request
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file and file.filename.endswith('.csv'):
        # Save uploaded file temporarily
        filename = secure_filename(file.filename)
        csv_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(csv_path)
        
        # Create output path
        excel_filename = os.path.splitext(filename)[0] + '.xlsx'
        excel_path = os.path.join(app.config['UPLOAD_FOLDER'], excel_filename)
        
        try:
            # Convert CSV to Excel
            df = pd.read_csv(csv_path)
            df.to_excel(excel_path, index=False, engine='openpyxl')
            
            # Return the Excel file
            return send_file(
                excel_path,
                mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                as_attachment=True,
                download_name=excel_filename
            )
        except Exception as e:
            return jsonify({"error": str(e)}), 500
        finally:
            # Clean up files
            if os.path.exists(csv_path):
                os.remove(csv_path)
            # Keep Excel file for a short time for download, it will be removed later
    else:
        return jsonify({"error": "File must be a CSV file (.csv)"}), 400

# Cleanup task to remove old files (in a production environment, you might use a scheduled task)
@app.route('/cleanup', methods=['POST'])
def cleanup():
    count = 0
    for filename in os.listdir(app.config['UPLOAD_FOLDER']):
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        try:
            if os.path.isfile(file_path):
                os.remove(file_path)
                count += 1
        except Exception as e:
            print(f"Error deleting {file_path}: {e}")
    
    return jsonify({"message": f"Removed {count} files"})

if __name__ == '__main__':
    app.run(debug=True)