"use client";

import React, { useState } from "react";
import { FileUpload } from "@/components/ui/file-upload";
import { Button } from "@/components/ui/button";
import { BACKEND_FLASK_URL } from "@/config/config";

const formats = ['jpeg', 'jpg', 'png', 'webp', 'bmp', 'gif', 'tiff'];

export default function ImageConverterPage() {
  const [file, setFile] = useState<File | null>(null);
  const [fromFormat, setFromFormat] = useState("png");
  const [toFormat, setToFormat] = useState("jpeg");
  const [isLoading, setIsLoading] = useState(false);

  const handleUpload = (files: File[]) => {
    if (files.length) {
      setFile(files[0]);
      const ext = files[0].name.split(".").pop()?.toLowerCase();
      if (formats.includes(ext || "")) {
        setFromFormat(ext || "png");
      }
    }
  };

  const handleConvert = async () => {
    if (!file || fromFormat === toFormat) {
      alert("Please upload a file and choose a different target format.");
      return;
    }

    const formData = new FormData();
    formData.append("image", file);
    formData.append("format", toFormat);

    setIsLoading(true);

    try {
      const res = await fetch(`${BACKEND_FLASK_URL}/convert_img`, {
        method: "POST",
        body: formData,
      });

      if (!res.ok) {
        const errorData = await res.json();
        alert(errorData.error || "Image conversion failed");
        return;
      }

      const blob = await res.blob();
      const downloadUrl = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = downloadUrl;
      link.download = file.name.replace(/\.[^/.]+$/, `.${toFormat}`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(downloadUrl);
    } catch (err) {
      console.error("Image conversion error:", err);
      alert("Something went wrong.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="w-full max-w-3xl mx-auto p-6">
      <h1 className="text-2xl font-semibold mb-6 text-black dark:text-white">Image Format Converter</h1>
      
      <FileUpload onChange={handleUpload} />
      
      {file && (
        <div className="mt-4 text-sm text-green-600">{file.name}</div>
      )}

      <div className="flex flex-col md:flex-row gap-4 mt-6">
        <div className="flex-1">
          <label className="block mb-1 text-sm text-black dark:text-white">Convert from:</label>
          <select
            className="w-full p-2 border rounded dark:bg-black dark:text-white"
            value={fromFormat}
            onChange={(e) => setFromFormat(e.target.value)}
          >
            {formats.map((format) => (
              <option key={format} value={format}>
                {format.toUpperCase()}
              </option>
            ))}
          </select>
        </div>

        <div className="flex-1">
          <label className="block mb-1 text-sm text-black dark:text-white">Convert to:</label>
          <select
            className="w-full p-2 border rounded dark:bg-black dark:text-white"
            value={toFormat}
            onChange={(e) => setToFormat(e.target.value)}
          >
            {formats.map((format) => (
              <option key={format} value={format}>
                {format.toUpperCase()}
              </option>
            ))}
          </select>
        </div>
      </div>

      <Button
        onClick={handleConvert}
        disabled={!file || isLoading}
        className="mt-6"
      >
        {isLoading ? "Converting..." : "Convert"}
      </Button>
    </div>
  );
}
