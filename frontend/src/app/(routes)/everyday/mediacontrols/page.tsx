'use client';

import React, { useState } from 'react';
import axios from 'axios';
import { Card } from '@/components/landing-card';
import { FileUpload } from '@/components/ui/file-upload';
import { BACKEND_FLASK_URL } from '@/config/config';

export default function MediaToolsPage() {
  const [action, setAction] = useState<'' | 'convert_video' | 'convert_audio' | 'trim_video' | 'trim_audio'>('');
  const [file, setFile] = useState<File | null>(null);
  const [format, setFormat] = useState('mp4');
  const [start, setStart] = useState('');
  const [end, setEnd] = useState('');
  const [output, setOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async () => {
    if (!file || !action) return;

    setLoading(true);
    setError('');
    setOutput('');

    const formData = new FormData();
    formData.append('file', file);

    if (action.includes('convert')) {
      formData.append('format', format);
    } else {
      formData.append('start', start);
      formData.append('end', end);
    }

    try {
      const res = await axios.post(`${BACKEND_FLASK_URL}/${action}`, formData, {
        responseType: 'blob',
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      const url = URL.createObjectURL(new Blob([res.data]));
      setOutput(url);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Something went wrong');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="w-full min-h-screen bg-black text-white p-6 flex flex-col items-center gap-6">
      <h2 className="text-3xl font-bold">Media Tools</h2>

      {/* Step 1: Select Action */}
      <div className="flex flex-wrap gap-4 justify-center">
        {['convert_video', 'convert_audio', 'trim_video', 'trim_audio'].map((type) => (
          <button
            key={type}
            onClick={() => {
              setAction(type as typeof action);
              setFile(null);
              setOutput('');
              setError('');
            }}
            className={`px-4 py-2 rounded ${action === type ? 'bg-white text-black' : 'bg-white/10 text-white'}`}
          >
            {type.replace('_', ' ').toUpperCase()}
          </button>
        ))}
      </div>

      {/* Step 2: Show relevant inputs */}
      {action && (
        <div className="w-full max-w-md mt-4 flex flex-col gap-4 items-center">
          {(action === 'convert_video' || action === 'convert_audio') && (
            <select
              value={format}
              onChange={(e) => setFormat(e.target.value)}
              className="bg-white/10 text-white px-4 py-2 rounded w-full"
            >
              <option value="mp4">mp4</option>
              <option value="mp3">mp3</option>
              <option value="wav">wav</option>
            </select>
          )}

          {(action === 'trim_video' || action === 'trim_audio') && (
            <div className="flex gap-4 w-full">
              <input
                type="number"
                placeholder="Start (sec)"
                value={start}
                onChange={(e) => setStart(e.target.value)}
                className="bg-white/10 text-white px-3 py-2 rounded w-1/2"
              />
              <input
                type="number"
                placeholder="End (sec)"
                value={end}
                onChange={(e) => setEnd(e.target.value)}
                className="bg-white/10 text-white px-3 py-2 rounded w-1/2"
              />
            </div>
          )}

          {/* Step 3: Upload file */}
          <FileUpload onChange={(f) => setFile(f[0])} />

          {/* Submit Button */}
          <button
            onClick={handleSubmit}
            disabled={!file}
            className="bg-white text-black px-6 py-2 mt-2 rounded w-full"
          >
            Submit
          </button>
        </div>
      )}

      {/* Output Section */}
      {loading && <p className="text-neutral-400 text-sm mt-4">Processing...</p>}
      {error && <p className="text-red-500 mt-4">{error}</p>}
      {output && (
        <div className="mt-6 text-center">
          <p className="text-neutral-400 text-sm mb-2">Output:</p>
          {action.includes('video') ? (
            <video controls className="w-full max-w-lg" src={output} />
          ) : (
            <audio controls className="w-full max-w-lg" src={output} />
          )}
          <a
            href={output}
            download
            className="mt-2 inline-block bg-white text-black px-4 py-2 rounded"
          >
            Download
          </a>
        </div>
      )}
    </Card>
  );
}