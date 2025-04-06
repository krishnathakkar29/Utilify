'use client';

import React, { useState } from 'react';
import axios from 'axios';
import { BACKEND_FLASK_URL } from '@/config/config';
import { Card } from '@/components/landing-card';

export default function ApiTesterPage() {
  const [url, setUrl] = useState('');
  const [method, setMethod] = useState('GET');
  const [headers, setHeaders] = useState('{}');
  const [data, setData] = useState('{}');
  const [token, setToken] = useState('');
  const [response, setResponse] = useState('');
  const [latency, setLatency] = useState<number | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    setError('');
    setResponse('');
    setLatency(null);

    let parsedHeaders = {};
    let parsedData = {};

    try {
      parsedHeaders = headers ? JSON.parse(headers) : {};
    } catch {
      setError('Invalid headers JSON');
      setLoading(false);
      return;
    }

    try {
      parsedData = data ? JSON.parse(data) : {};
    } catch {
      setError('Invalid data JSON');
      setLoading(false);
      return;
    }

    try {
      const res = await axios.post(`${BACKEND_FLASK_URL}/api/test`, {
        url,
        method,
        headers: parsedHeaders,
        data: parsedData,
        token,
      });

      setResponse(
        typeof res.data.response === 'object'
          ? JSON.stringify(res.data.response, null, 2)
          : res.data.response
      );
      setLatency(res.data.latency_ms);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Server error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="w-full min-h-screen bg-black text-white p-6 flex flex-col items-center gap-6">
      <h2 className="text-3xl font-bold">API Tester</h2>

      <div className="w-full max-w-2xl flex flex-col gap-4">
        {/* URL */}
        <div className="flex flex-col gap-1">
          <label className="text-sm text-neutral-300">API URL</label>
          <input
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            placeholder="Enter API URL"
            className="bg-white/10 text-white px-4 py-2 rounded"
          />
        </div>

        {/* Method and Token */}
        <div className="flex gap-4">
          <div className="w-1/2 flex flex-col gap-1">
            <label className="text-sm text-neutral-300">HTTP Method</label>
            <select
              value={method}
              onChange={(e) => setMethod(e.target.value)}
              className="bg-white/10 text-white px-4 py-2 rounded"
            >
              {['GET', 'POST', 'PUT', 'DELETE'].map((m) => (
                <option key={m} value={m}>
                  {m}
                </option>
              ))}
            </select>
          </div>

          <div className="w-1/2 flex flex-col gap-1">
            <label className="text-sm text-neutral-300">Bearer Token (Optional)</label>
            <input
              value={token}
              onChange={(e) => setToken(e.target.value)}
              placeholder="Token"
              className="bg-white/10 text-white px-4 py-2 rounded"
            />
          </div>
        </div>

        {/* Headers */}
        <div className="flex flex-col gap-1">
          <label className="text-sm text-neutral-300">Headers (JSON)</label>
          <textarea
            value={headers}
            onChange={(e) => setHeaders(e.target.value)}
            placeholder='e.g. { "Content-Type": "application/json" }'
            rows={3}
            className="bg-white/10 text-white px-4 py-2 rounded font-mono"
          />
        </div>

        {/* Data */}
        <div className="flex flex-col gap-1">
          <label className="text-sm text-neutral-300">Request Body (JSON)</label>
          <textarea
            value={data}
            onChange={(e) => setData(e.target.value)}
            placeholder='e.g. { "name": "John" }'
            rows={4}
            className="bg-white/10 text-white px-4 py-2 rounded font-mono"
          />
        </div>

        {/* Submit */}
        <button
          onClick={handleSubmit}
          disabled={loading}
          className="bg-white text-black px-6 py-2 rounded"
        >
          {loading ? 'Sending...' : 'Send Request'}
        </button>

        {/* Error */}
        {error && <p className="text-red-500">{error}</p>}

        {/* Latency */}
        {latency !== null && (
          <p className="text-green-400 text-sm">Latency: {latency} ms</p>
        )}

        {/* Response */}
        {response && (
          <pre className="bg-white/10 p-4 rounded overflow-x-auto text-sm mt-4 whitespace-pre-wrap">
            {response}
          </pre>
        )}
      </div>
    </Card>
  );
}
