'use client';

import React, { useState } from 'react';
import axios from 'axios';
import { cn } from "@/lib/utils";
import { FileUpload } from "@/components/ui/file-upload";
import { Card } from "@/components/landing-card";
import { Button } from "@/components/ui/button";
import { BACKEND_FLASK_URL } from "@/config/config";

export default function pages() {
  const [file, setFile] = useState<File | null>(null);
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async () => {
    if (!file) {
      setError("Please upload an image first.");
      return;
    }

    setLoading(true);
    setError('');
    setText('');

    const formData = new FormData();
    formData.append('image', file);

    try {
      const res = await axios.post(`${BACKEND_FLASK_URL}/ocr`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      
      if (res.data.text) {
        setText(res.data.text);
      } else {
        setError('No text extracted.');
      }
    } catch (err: any) {
      setError(err.response?.data?.error || 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="w-full min-h-screen bg-black text-white p-6 flex flex-col items-center gap-8">
      <div className="text-3xl font-semibold text-center">Image to Text (OCR)</div>

      <FileUpload
        onChange={(files) => {
          if (files.length > 0) setFile(files[0]);
        }}
      />

      <Button 
        onClick={handleSubmit}
        className="bg-white text-black hover:bg-neutral-200 transition mt-4"
        disabled={!file || loading}
      >
        {loading ? 'Extracting...' : 'Submit'}
      </Button>

      {error && <p className="text-red-500 text-sm mt-4">{error}</p>}
      {text && (
        <div className="w-full max-w-3xl mt-6 p-4 bg-white/10 rounded-lg whitespace-pre-wrap text-base">
          {text}
        </div>
      )}
    </Card>
  );
}
