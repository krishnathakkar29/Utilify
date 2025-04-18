"use client";

import React, { useState } from "react";
import { FileUpload } from "@/components/ui/file-upload";
import { Button } from "@/components/ui/button";
import { BACKEND_FLASK_URL } from "@/config/config";

function ExcelToCSVUpload() {
  const [file, setFile] = useState<File | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleFileSelect = (files: File[]) => {
    if (files.length) setFile(files[0]);
  };

  const handleConvert = async () => {
    if (!file) return alert("Please upload an Excel file.");

    const formData = new FormData();
    formData.append("file", file);
    setIsLoading(true);

    try {
      const res = await fetch(`${BACKEND_FLASK_URL}/excel-to-csv`, {
        method: "POST",
        body: formData,
      });

      if (!res.ok) {
        const errorData = await res.json();
        alert(errorData.error || "Conversion failed");
        return;
      }

      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = file.name.replace(/\.(xlsx|xls)$/i, ".csv");
      link.click();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
      alert("Something went wrong.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="w-full h-full border border-dashed bg-white dark:bg-black border-neutral-200 dark:border-neutral-800 rounded-lg p-4 flex flex-col justify-center items-center">
      <h2 className="text-lg font-semibold mb-4 text-black dark:text-white">Excel to CSV</h2>
      <FileUpload onChange={handleFileSelect} />
      {file && <p className="mt-2 text-sm text-green-600">{file.name}</p>}
      <Button
        className="mt-4"
        onClick={handleConvert}
        disabled={!file || isLoading}
      >
        {isLoading ? "Converting..." : "Convert"}
      </Button>
    </div>
  );
}

function CSVToExcelUpload() {
  const [file, setFile] = useState<File | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleFileSelect = (files: File[]) => {
    if (files.length) setFile(files[0]);
  };

  const handleConvert = async () => {
    if (!file) return alert("Please upload a CSV file.");

    const formData = new FormData();
    formData.append("file", file);
    setIsLoading(true);

    try {
      const res = await fetch(`${BACKEND_FLASK_URL}/csv-to-excel`, {
        method: "POST",
        body: formData,
      });

      if (!res.ok) {
        const errorData = await res.json();
        alert(errorData.error || "Conversion failed");
        return;
      }

      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = file.name.replace(/\.csv$/i, ".xlsx");
      link.click();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
      alert("Something went wrong.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="w-full h-full border border-dashed bg-white dark:bg-black border-neutral-200 dark:border-neutral-800 rounded-lg p-4 flex flex-col justify-center items-center">
      <h2 className="text-lg font-semibold mb-4 text-black dark:text-white">CSV to Excel</h2>
      <FileUpload onChange={handleFileSelect} />
      {file && <p className="mt-2 text-sm text-green-600">{file.name}</p>}
      <Button
        className="mt-4"
        onClick={handleConvert}
        disabled={!file || isLoading}
      >
        {isLoading ? "Converting..." : "Convert"}
      </Button>
    </div>
  );
}

export default function Page() {
  return (
    <div className="w-full h-full flex items-center justify-center overflow-x-hidden overflow-y-auto p-4">
      <div className="w-full max-w-6xl grid grid-cols-1 md:grid-cols-2 gap-6">
        <ExcelToCSVUpload />
        <CSVToExcelUpload />
      </div>
    </div>
  );
}
