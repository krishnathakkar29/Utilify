"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import axios from "axios";
import { Loader2, FilePlus2, FileX, Scissors, File } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { toast } from "sonner";
import { BACKEND_FLASK_URL } from "@/config/config";

const PDFSplit = () => {
  const [file, setFile] = useState<File | null>(null);
  const [startPage, setStartPage] = useState<string>("1");
  const [endPage, setEndPage] = useState<string>("1");
  const [loading, setLoading] = useState(false);
  const [totalPages, setTotalPages] = useState<number>(0);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];

      if (selectedFile.type !== "application/pdf") {
        toast.error("Invalid file type. Please select a PDF file to split.");
        return;
      }

      setFile(selectedFile);
      // Simulate getting total pages - in a real app, you'd extract this from the PDF
      // For now we'll just set a dummy value
      const estimatedPages = Math.floor(selectedFile.size / 30000) + 1; // Rough estimate
      setTotalPages(Math.max(1, Math.min(100, estimatedPages)));
      setEndPage(String(estimatedPages));
    }
  };

  const handlePageChange = (type: "start" | "end", value: string) => {
    const pageNum = parseInt(value) || 1;

    if (type === "start") {
      setStartPage(String(Math.max(1, Math.min(totalPages, pageNum))));
    } else {
      setEndPage(
        String(Math.max(parseInt(startPage), Math.min(totalPages, pageNum)))
      );
    }
  };

  const handleSplit = async () => {
    if (!file) {
      toast.error("Please select a PDF file to split.");
      return;
    }

    setLoading(true);

    try {
      const formData = new FormData();
      formData.append("file", file);
      formData.append("start_page", startPage);
      formData.append("end_page", endPage);

      const response = await axios.post(
        `${BACKEND_FLASK_URL}/split`,
        formData,
        {
          responseType: "blob",
        }
      );

      // Create a download link for the split file
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", `split_${startPage}-${endPage}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();

      toast.success("PDF split successfully! Downloading...");
    } catch (error) {
      console.error("Error splitting PDF:", error);
      toast.error("Failed to split the PDF. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col space-y-6">
      {!file ? (
        <div className="flex flex-col items-center justify-center border-2 border-dashed border-border rounded-lg p-12 transition-colors hover:border-muted-foreground/50 cursor-pointer">
          <input
            id="file-upload-split"
            type="file"
            accept=".pdf"
            className="hidden"
            onChange={handleFileChange}
          />
          <label
            htmlFor="file-upload-split"
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
                Select a single PDF file to split
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
              onClick={() => {
                setFile(null);
                setStartPage("1");
                setEndPage("1");
                setTotalPages(0);
              }}
              aria-label="Remove file"
            >
              <FileX className="h-4 w-4" />
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="start-page">Start Page</Label>
              <Input
                id="start-page"
                type="number"
                min={1}
                max={totalPages}
                value={startPage}
                onChange={(e) => handlePageChange("start", e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="end-page">End Page</Label>
              <Input
                id="end-page"
                type="number"
                min={parseInt(startPage)}
                max={totalPages}
                value={endPage}
                onChange={(e) => handlePageChange("end", e.target.value)}
              />
            </div>
          </div>

          {totalPages > 0 && (
            <p className="text-sm text-muted-foreground">
              This PDF has approximately {totalPages} pages. You're extracting
              pages {startPage} to {endPage}.
            </p>
          )}

          <div className="flex justify-end">
            <Button
              onClick={handleSplit}
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
                  <Scissors className="mr-2 h-4 w-4" />
                  Split PDF
                </>
              )}
            </Button>
          </div>
        </>
      )}

      {!file && (
        <Alert className="bg-secondary/40 border-0">
          <AlertTitle className="flex items-center gap-2">
            <Scissors className="h-4 w-4" />
            Getting Started
          </AlertTitle>
          <AlertDescription className="text-sm text-muted-foreground">
            Upload a PDF file and specify which pages you want to extract. The
            tool will create a new PDF containing only those pages.
          </AlertDescription>
        </Alert>
      )}
    </div>
  );
};

export default PDFSplit;
