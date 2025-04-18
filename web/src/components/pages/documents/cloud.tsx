"use client";
import React, { useState } from "react";
import { FileUpload } from "@/components/ui/file-upload";
import { BACKEND_FLASK_URL } from "@/config/config";
import { toast, Toaster } from "sonner";
import { ClipboardCopy } from "lucide-react";

function Cloud() {
  const [file, setFile] = useState<File | null>(null);
  const [submittedLink, setSubmittedLink] = useState<string | null>(null);
  const [expiration, setExpiration] = useState<number>(60);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async () => {
    if (!file) return;

    const formData = new FormData();
    formData.append("file", file);
    formData.append("expiration", expiration.toString());

    try {
      setLoading(true);
      setError(null);
      const response = await fetch(`${BACKEND_FLASK_URL}/upload`, {
        method: "POST",
        body: formData,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Upload failed");
      }

      setSubmittedLink(data.presigned_url);
      toast.success("Presigned URL generated!");
    } catch (err: any) {
      setError(err.message);
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleCopy = () => {
    if (submittedLink) {
      navigator.clipboard.writeText(submittedLink);
      toast.success("Copied to clipboard!");
    }
  };

  return (
    <div className="min-h-screen bg-zinc-900 text-white p-6">
      <Toaster position="top-right" theme="dark" />

      <h1 className="text-2xl font-semibold mb-4 text-center">
        Cloud File Storage
      </h1>

      <FileUpload onChange={(files) => setFile(files[0])} />

      <div className="mt-6 flex flex-col items-center gap-3">
        <label htmlFor="expiration" className="text-sm text-zinc-300">
          Expiration time (in seconds)
        </label>
        <input
          id="expiration"
          type="number"
          min={1}
          value={expiration}
          onChange={(e) => setExpiration(Number(e.target.value))}
          className="px-3 py-2 rounded bg-zinc-800 text-white w-60 text-center"
        />

        <button
          onClick={handleSubmit}
          disabled={!file || loading}
          className="bg-purple-600 hover:bg-purple-700 px-4 py-2 rounded disabled:opacity-50"
        >
          {loading ? "Uploading..." : "Submit"}
        </button>

        {error && <p className="text-red-500 mt-2">{error}</p>}

        {submittedLink && (
          <div className="mt-4 flex flex-col items-center gap-2">
            <p className="text-green-400">Presigned URL:</p>
            <div className="flex items-center gap-2">
              <a
                href={submittedLink}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-400 underline break-all max-w-md"
              >
                {submittedLink}
              </a>
              <button
                onClick={handleCopy}
                className="p-1 text-white hover:text-green-400"
              >
                <ClipboardCopy size={18} />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Cloud;
