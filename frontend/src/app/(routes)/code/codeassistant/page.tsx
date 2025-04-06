'use client';

import React, { useState } from 'react';
import axios from 'axios';
import { BACKEND_FLASK_URL } from '@/config/config';
import { Card } from '@/components/landing-card';

export default function CodeAssistantPage() {
  const [query, setQuery] = useState('');
  const [language, setLanguage] = useState('en');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const languages: { [key: string]: string } = {
    en: 'English',
    hi: 'Hindi',
    fr: 'French',
    es: 'Spanish',
    de: 'German',
    // Add more if supported by backend
  };

  const handleSubmit = async () => {
    if (!query.trim()) return;

    setLoading(true);
    setError('');
    setResponse('');

    try {
      const res = await axios.post(`${BACKEND_FLASK_URL}/code_assistant`, {
        query,
        language,
      });

      if (res.data.status === 'success') {
        setResponse(res.data.response);
      } else {
        setError(res.data.error || 'Something went wrong');
      }
    } catch (err: any) {
      setError(err.response?.data?.error || 'Server error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="w-full min-h-screen p-6 bg-black text-white flex flex-col items-center gap-6">
      <h2 className="text-3xl font-bold">Code Assistant</h2>

      <div className="w-full max-w-2xl flex flex-col gap-4">
        <select
          value={language}
          onChange={(e) => setLanguage(e.target.value)}
          className="bg-white/10 text-white px-4 py-2 rounded"
        >
          {Object.entries(languages).map(([code, name]) => (
            <option key={code} value={code}>
              {name}
            </option>
          ))}
        </select>

        <textarea
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Enter your code question here..."
          rows={4}
          className="bg-white/10 text-white px-4 py-2 rounded"
        />

        <button
          onClick={handleSubmit}
          disabled={loading}
          className="bg-white text-black px-4 py-2 rounded"
        >
          {loading ? 'Processing...' : 'Ask'}
        </button>

        {error && <p className="text-red-500">{error}</p>}

        {response && (
          <div className="bg-white/10 p-4 rounded mt-4 text-sm whitespace-pre-wrap">
            {response}
          </div>
        )}
      </div>
    </Card>
  );
}
