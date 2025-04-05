"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";

import axios from "axios";
import { Loader2, FilePlus2, FileX, Upload, File } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { toast } from "sonner";

const PDFMerge = () => {
  const [files, setFiles] = useState<File[]>([]);
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const selectedFiles = Array.from(e.target.files);
      const pdfFiles = selectedFiles.filter(
        (file) => file.type === "application/pdf"
      );

      if (pdfFiles.length !== selectedFiles.length) {
        toast.error("Invalid file type. Please select only PDF files.");
        return;
      }

      setFiles((prevFiles) => [...prevFiles, ...pdfFiles]);
    }
  };

  const removeFile = (index: number) => {
    setFiles(files.filter((_, i) => i !== index));
  };

  const handleMerge = async () => {
    if (files.length < 2) {
      toast.error("Please select at least two PDF files to merge them.");
      return;
    }

    setLoading(true);

    try {
      const formData = new FormData();
      files.forEach((file) => {
        formData.append("files", file);
      });

      const response = await axios.post(
        "http://localhost:5000/merge",
        formData,
        {
          responseType: "blob",
        }
      );

      // Create a download link for the merged file
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", "merged.pdf");
      document.body.appendChild(link);
      link.click();
      link.remove();

      toast.success("PDFs merged successfully!");

      setFiles([]);
    } catch (error) {
      console.error("Error merging PDFs:", error);
      toast.error("Failed to merge PDFs. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col space-y-6">
      <div className="flex flex-col items-center justify-center border-2 border-dashed border-border rounded-lg p-12 transition-colors hover:border-muted-foreground/50 cursor-pointer">
        <input
          id="file-upload-merge"
          type="file"
          multiple
          accept=".pdf"
          className="hidden"
          onChange={handleFileChange}
        />
        <label
          htmlFor="file-upload-merge"
          className="cursor-pointer flex flex-col items-center space-y-2 text-center"
        >
          <div className="rounded-full bg-secondary p-4">
            <FilePlus2 className="h-8 w-8 text-muted-foreground" />
          </div>
          <div className="flex flex-col space-y-1">
            <span className="font-medium">
              Drop your PDF files here or click to browse
            </span>
            <span className="text-xs text-muted-foreground">
              Supports multiple PDF files
            </span>
          </div>
        </label>
      </div>

      {files.length > 0 && (
        <>
          <div className="space-y-2">
            <div className="text-sm font-medium">
              Selected Files ({files.length})
            </div>
            <div className="max-h-80 overflow-y-auto space-y-2 border rounded-lg p-2">
              {files.map((file, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between bg-secondary/40 rounded-lg p-3"
                >
                  <div className="flex items-center space-x-3">
                    <File className="h-5 w-5 text-accent" />
                    <div className="text-sm font-medium truncate max-w-[250px] md:max-w-[400px]">
                      {file.name}
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {(file.size / 1024).toFixed(2)} KB
                    </span>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => removeFile(index)}
                    aria-label="Remove file"
                  >
                    <FileX className="h-4 w-4" />
                  </Button>
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-end">
            <Button
              onClick={handleMerge}
              disabled={loading || files.length < 2}
              className="w-full sm:w-auto"
            >
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Processing...
                </>
              ) : (
                <>
                  <Upload className="mr-2 h-4 w-4" />
                  Merge PDFs
                </>
              )}
            </Button>
          </div>
        </>
      )}

      {files.length === 0 && (
        <Alert className="bg-secondary/40 border-0">
          <AlertTitle className="flex items-center gap-2">
            <FilePlus2 className="h-4 w-4" />
            Getting Started
          </AlertTitle>
          <AlertDescription className="text-sm text-muted-foreground">
            Select multiple PDF files to merge them into a single document. The
            files will be merged in the order they appear in the list.
          </AlertDescription>
        </Alert>
      )}
    </div>
  );
};

export default PDFMerge;
