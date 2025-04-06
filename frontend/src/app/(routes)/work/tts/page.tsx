'use client';

import React, { useState, useEffect } from 'react';
import { Card } from "@/components/landing-card";
import { Spotlight } from "@/components/ui/spotlight";
import { BACKEND_FLASK_URL } from "@/config/config";

export default function Page() {
  const [text, setText] = useState('');
  const [voice, setVoice] = useState('alloy');
  const [loading, setLoading] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [audioRef] = useState(new Audio());
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);

  const handleGenerate = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${BACKEND_FLASK_URL}/tts`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text, voice }),
      });

      if (!response.ok) {
        const errData = await response.json();
        throw new Error(errData.error || 'Something went wrong');
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);

      audioRef.pause();
      audioRef.src = url;
      setAudioUrl(url);
      setIsPlaying(true);
      audioRef.play();

      audioRef.onended = () => setIsPlaying(false);
    } catch (err) {
      const error = err as Error;
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const updateProgress = () => {
      if (!audioRef.paused) {
        setProgress(audioRef.currentTime);
      }
    };
    const interval = setInterval(updateProgress, 500);
    return () => clearInterval(interval);
  }, [audioRef]);

  return (
    <Card className="w-full h-screen bg-black/[0.96] relative overflow-hidden px-6 py-10 text-white">
      <Spotlight className="-top-40 left-0 md:left-60 md:-top-20" />

      <div className="relative z-10 max-w-2xl mx-auto space-y-6">
        <h1 className="text-4xl md:text-5xl font-bold text-white">
          Text to Speech
        </h1>

        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          rows={5}
          placeholder="Enter text to convert to speech..."
          className="w-full bg-neutral-900 text-white p-4 rounded-lg border border-neutral-700 placeholder:text-neutral-500 resize-none"
        />

        <div className="flex flex-col sm:flex-row items-center gap-4">
          <select
            value={voice}
            onChange={(e) => setVoice(e.target.value)}
            className="bg-neutral-900 text-white border border-neutral-700 rounded px-4 py-2"
          >
            <option value="alloy">Alloy</option>
            <option value="echo">Echo</option>
            <option value="fable">Fable</option>
            <option value="onyx">Onyx</option>
            <option value="nova">Nova</option>
            <option value="shimmer">Shimmer</option>
          </select>

          <button
            onClick={handleGenerate}
            disabled={loading || !text}
            className="bg-white text-black font-semibold px-6 py-2 rounded hover:bg-neutral-200 transition"
          >
            {loading ? 'Generating...' : 'Generate'}
          </button>
        </div>

        {audioUrl && (
          <div className="mt-6 flex items-center gap-4">
            <button
              onClick={() => {
                if (isPlaying) {
                  audioRef.pause();
                } else {
                  audioRef.play();
                }
                setIsPlaying(!isPlaying);
              }}
              className="px-4 py-2 rounded-full text-sm font-medium bg-white text-black hover:bg-gray-300 transition"
            >
              {isPlaying ? 'Pause' : 'Play'}
            </button>

            <input
              type="range"
              min={0}
              max={audioRef.duration || 0}
              value={progress}
              onChange={(e) => {
                audioRef.currentTime = Number(e.target.value);
              }}
              className="w-full max-w-md h-2 rounded-lg bg-gray-700 cursor-pointer"
            />
          </div>
        )}
      </div>
    </Card>
  );
}
