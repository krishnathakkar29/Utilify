"use client";

import type React from "react";

import { useState } from "react";
import { Upload, X, Palette, Download, Copy, RefreshCw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { BACKEND_FLASK_URL } from "@/config/config";

interface ColorData {
  hex: string;
  rgb: [number, number, number];
  pixels: number;
}

function page() {
  const [isDragging, setIsDragging] = useState(false);
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [colors, setColors] = useState<ColorData[]>([]);
  const [paletteImage, setPaletteImage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);

    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const droppedFile = e.dataTransfer.files[0];
      if (droppedFile.type.startsWith("image/")) {
        handleFile(droppedFile);
      } else {
        setError("Please upload an image file");
      }
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const selectedFile = e.target.files[0];
      if (selectedFile.type.startsWith("image/")) {
        handleFile(selectedFile);
      } else {
        setError("Please upload an image file");
      }
    }
  };

  const handleFile = (file: File) => {
    setFile(file);
    setError(null);

    // Create preview
    const reader = new FileReader();
    reader.onload = (e) => {
      if (e.target?.result) {
        setPreview(e.target.result as string);
      }
    };
    reader.readAsDataURL(file);

    // Extract colors
    extractColors(file);
  };

  const extractColors = async (file: File) => {
    setIsLoading(true);
    setColors([]);
    setPaletteImage(null);

    try {
      const formData = new FormData();
      formData.append("image", file);
      const response = await fetch(`${BACKEND_FLASK_URL}/extract-colors`, {
        method: "POST",
        body: formData,
      });

      console.log(response);

      if (!response.ok) {
        throw new Error("Failed to extract colors");
      }

      const data = await response.json();
      setColors(data.colors);
      setPaletteImage(data.palette_image_base64);
    } catch (err) {
      setError("Failed to extract colors. Please try again.");
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard
      .writeText(text)
      .then(() => {
        // Could add a toast notification here
      })
      .catch((err) => {
        console.error("Failed to copy: ", err);
      });
  };

  const resetUpload = () => {
    setFile(null);
    setPreview(null);
    setColors([]);
    setPaletteImage(null);
    setError(null);
  };

  // New function to download the palette image
  const downloadPalette = () => {
    if (!paletteImage) return;

    // Create a temporary link element
    const link = document.createElement("a");
    link.href = `data:image/png;base64,${paletteImage}`;
    link.download = "color-palette.png";

    // Append to body, click and remove
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // New function to download palette data as JSON
  const downloadPaletteData = () => {
    if (colors.length === 0) return;

    const data = JSON.stringify(colors, null, 2);
    const blob = new Blob([data], { type: "application/json" });
    const url = URL.createObjectURL(blob);

    const link = document.createElement("a");
    link.href = url;
    link.download = "color-palette-data.json";

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    URL.revokeObjectURL(url);
  };

  return (
    <div className="container mx-auto px-4 py-12 max-w-5xl">
      <div className="text-center mb-10">
        <h1 className="text-4xl font-bold mb-3 bg-gradient-to-r from-purple-400 via-pink-500 to-red-500 text-transparent bg-clip-text">
          Color Palette Generator
        </h1>
        <p className="text-muted-foreground">
          Upload an image to extract a beautiful color palette
        </p>
      </div>

      {/* Changed to a single column layout */}
      <div className="space-y-8">
        {!file ? (
          <div
            className={`border-2 border-dashed rounded-xl h-80 flex flex-col items-center justify-center p-6 transition-all duration-200 ${
              isDragging
                ? "border-primary bg-primary/5"
                : "border-border hover:border-primary/50 hover:bg-secondary/50"
            }`}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
          >
            <div className="w-16 h-16 rounded-full bg-secondary flex items-center justify-center mb-4">
              <Upload className="w-8 h-8 text-primary" />
            </div>
            <h3 className="text-xl font-medium mb-2">Drop your image here</h3>
            <p className="text-muted-foreground text-center mb-4">
              or click to browse from your device
            </p>
            <Button variant="outline" className="relative">
              Choose Image
              <input
                type="file"
                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                onChange={handleFileChange}
                accept="image/*"
              />
            </Button>
          </div>
        ) : (
          <div className="relative rounded-xl overflow-hidden bg-black/5 backdrop-blur-sm border border-white/10">
            <div className="absolute top-4 right-4 z-10">
              <Button
                variant="secondary"
                size="icon"
                className="rounded-full bg-black/30 backdrop-blur-md hover:bg-black/50"
                onClick={resetUpload}
              >
                <X className="w-4 h-4" />
              </Button>
            </div>
            {preview && (
              <div className="aspect-video w-full flex items-center justify-center overflow-hidden">
                <img
                  src={preview || "/placeholder.svg"}
                  alt="Preview"
                  className="w-full h-full object-contain"
                />
              </div>
            )}
          </div>
        )}

        {error && (
          <div className="p-4 bg-destructive/10 border border-destructive/20 rounded-lg text-destructive">
            {error}
          </div>
        )}

        {isLoading && (
          <div className="flex items-center justify-center p-8">
            <RefreshCw className="w-6 h-6 animate-spin text-primary" />
            <span className="ml-2">Extracting colors...</span>
          </div>
        )}

        {/* Palette and colors now appear below the image */}
        {paletteImage && (
          <Card className="overflow-hidden p-0 border border-white/10">
            <div className="p-4 bg-black/20 backdrop-blur-sm">
              <h3 className="text-lg font-medium flex items-center">
                <Palette className="w-5 h-5 mr-2" />
                Generated Palette
              </h3>
            </div>
            <div className="p-4">
              <img
                src={`data:image/png;base64,${paletteImage}`}
                alt="Color Palette"
                className="w-full rounded-lg shadow-lg"
              />
            </div>
          </Card>
        )}

        {colors.length > 0 && (
          <Card className="overflow-hidden border border-white/10">
            <div className="p-4 bg-black/20 backdrop-blur-sm">
              <h3 className="text-lg font-medium">Color Codes</h3>
            </div>
            <div className="p-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {colors.map((color, index) => (
                <div
                  key={index}
                  className="flex items-center p-3 rounded-lg transition-all hover:bg-black/10"
                >
                  <div
                    className="w-12 h-12 rounded-lg mr-4 shadow-md"
                    style={{ backgroundColor: color.hex }}
                  />
                  <div className="flex-1">
                    <div className="font-mono text-lg">{color.hex}</div>
                    <div className="text-sm text-muted-foreground">
                      RGB: {color.rgb.join(", ")}
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="ml-2"
                    onClick={() => copyToClipboard(color.hex)}
                  >
                    <Copy className="w-4 h-4" />
                  </Button>
                </div>
              ))}
            </div>
          </Card>
        )}

        {colors.length > 0 && (
          <div className="flex justify-end gap-3">
            <Button
              variant="outline"
              className="gap-2"
              onClick={downloadPaletteData}
            >
              <Download className="w-4 h-4" />
              Download Data
            </Button>
            <Button className="gap-2" onClick={downloadPalette}>
              <Download className="w-4 h-4" />
              Download Palette
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}

export default page;
