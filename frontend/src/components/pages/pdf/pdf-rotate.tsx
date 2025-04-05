"use client";
import { Button } from "@/components/ui/button";
import { useState } from "react";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import axios from "axios";
import { File, FilePlus2, FileX, Loader2, RotateCw } from "lucide-react";
import { toast } from "sonner";

const PDFRotate = () => {
  const [file, setFile] = useState<File | null>(null);
  const [angle, setAngle] = useState<number>(90);
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];

      if (selectedFile.type !== "application/pdf") {
        toast.error("Invalid file type. Please select a PDF file to rotate.");
        return;
      }

      setFile(selectedFile);
    }
  };

  const handleRotate = async () => {
    if (!file) {
      toast.error("Please select a PDF file to rotate.");
      return;
    }

    setLoading(true);

    try {
      const formData = new FormData();
      formData.append("file", file);
      formData.append("angle", String(angle));

      const response = await axios.post(
        "http://localhost:5000/rotate",
        formData,
        {
          responseType: "blob",
        }
      );

      // Create a download link for the rotated file
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", `rotated_${angle}_${file.name}`);
      document.body.appendChild(link);
      link.click();
      link.remove();

      toast.success("PDF rotated successfully! Downloading...");
    } catch (error) {
      console.error("Error rotating PDF:", error);
      toast.error("Failed to rotate the PDF. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col space-y-6">
      {!file ? (
        <div className="flex flex-col items-center justify-center border-2 border-dashed border-border rounded-lg p-12 transition-colors hover:border-muted-foreground/50 cursor-pointer">
          <input
            id="file-upload-rotate"
            type="file"
            accept=".pdf"
            className="hidden"
            onChange={handleFileChange}
          />
          <label
            htmlFor="file-upload-rotate"
            className="cursor-pointer flex flex-col items-center space-y-2 text-center"
          >
            <div className="rounded-full bg-secondary p-4">
              <FilePlus2 className="h-8 w-8 text-muted-foreground" />
            </div>
            <div className="flex flex-col space-y-1">
              <span className="font-medium">
                Drop your PDF file here or click to browse
              </span>
              <span className="text-xs text-muted-foreground">
                Select a PDF file to rotate its pages
              </span>
            </div>
          </label>
        </div>
      ) : (
        <>
          <div className="flex items-center justify-between bg-secondary/40 rounded-lg p-3">
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
              onClick={() => setFile(null)}
              aria-label="Remove file"
            >
              <FileX className="h-4 w-4" />
            </Button>
          </div>

          <div className="space-y-4">
            <div className="text-sm font-medium">Select rotation angle:</div>
            <Tabs
              value={String(angle)}
              onValueChange={(value) => setAngle(parseInt(value))}
              className="w-full"
            >
              <TabsList className="grid grid-cols-4">
                <TabsTrigger value="90" className="flex items-center space-x-1">
                  <RotateCw className="h-4 w-4" />
                  <span>90°</span>
                </TabsTrigger>
                <TabsTrigger
                  value="180"
                  className="flex items-center space-x-1"
                >
                  <RotateCw className="h-4 w-4" />
                  <span>180°</span>
                </TabsTrigger>
                <TabsTrigger
                  value="270"
                  className="flex items-center space-x-1"
                >
                  <RotateCw className="h-4 w-4" />
                  <span>270°</span>
                </TabsTrigger>
                <TabsTrigger
                  value="360"
                  className="flex items-center space-x-1"
                >
                  <RotateCw className="h-4 w-4" />
                  <span>360°</span>
                </TabsTrigger>
              </TabsList>
            </Tabs>
          </div>

          <div className="flex justify-end">
            <Button
              onClick={handleRotate}
              disabled={loading || !file}
              className="w-full sm:w-auto"
            >
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Processing...
                </>
              ) : (
                <>
                  <RotateCw className="mr-2 h-4 w-4" />
                  Rotate PDF
                </>
              )}
            </Button>
          </div>
        </>
      )}

      {!file && (
        <Alert className="bg-secondary/40 border-0">
          <AlertTitle className="flex items-center gap-2">
            <RotateCw className="h-4 w-4" />
            Getting Started
          </AlertTitle>
          <AlertDescription className="text-sm text-muted-foreground">
            Upload a PDF file and select a rotation angle. All pages in the
            document will be rotated by the specified angle.
          </AlertDescription>
        </Alert>
      )}
    </div>
  );
};

export default PDFRotate;
