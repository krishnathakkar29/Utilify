'use client';

import React, { useState, useRef, useEffect } from "react";
import { FileUpload } from "@/components/ui/file-upload";
import { BACKEND_FLASK_URL } from "@/config/config";

type Message = {
  type: "user" | "bot";
  text: string;
};

const Page = () => {
  const [files, setFiles] = useState<File[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [question, setQuestion] = useState("");
  const [loading, setLoading] = useState(false);
  const chatEndRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleUpload = async () => {
    if (!files.length) return;

    const formData = new FormData();
    files.forEach((file) => formData.append("files", file));

    try {
      setLoading(true);
      const res = await fetch(`${BACKEND_FLASK_URL}/process_pdfs`, {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to process PDFs");
      alert("PDFs processed successfully!");
    } catch (err: any) {
      alert(err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleAsk = async () => {
    if (!question.trim()) return;

    const userMsg: Message = { type: "user", text: question };
    setMessages((prev) => [...prev, userMsg]);
    setQuestion("");

    try {
      const res = await fetch(`${BACKEND_FLASK_URL}/ask_question`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question }),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to get response");

      const botMsg: Message = { type: "bot", text: data.response };
      setMessages((prev) => [...prev, botMsg]);
    } catch (err: any) {
      const errMsg: Message = { type: "bot", text: "Error: " + err.message };
      setMessages((prev) => [...prev, errMsg]);
    }
  };

  return (
    <div className="min-h-screen bg-zinc-900 text-white p-6">
      <h1 className="text-2xl font-semibold mb-6 text-center">Document Querying</h1>

      <div className="flex flex-col items-center mb-8">
        <FileUpload onChange={(selectedFiles) => setFiles(selectedFiles)} />
        <button
          onClick={handleUpload}
          disabled={!files.length || loading}
          className="mt-4 bg-purple-600 hover:bg-purple-700 px-6 py-2 rounded disabled:opacity-50"
        >
          {loading ? "Processing..." : "Process PDFs"}
        </button>
      </div>

      <div className="max-w-2xl mx-auto bg-zinc-800 p-6 rounded-xl shadow-md">
        <div className="h-80 overflow-y-auto space-y-4 mb-4 flex flex-col">
          {messages.map((msg, idx) => (
            <div
              key={idx}
              className={`max-w-[80%] px-4 py-2 rounded-xl ${
                msg.type === "user"
                  ? "bg-purple-600 self-end text-white"
                  : "bg-zinc-700 self-start text-white"
              }`}
            >
              {msg.text}
            </div>
          ))}
          <div ref={chatEndRef} />
        </div>

        <div className="flex gap-2">
          <input
            type="text"
            placeholder="Ask a question..."
            value={question}
            onChange={(e) => setQuestion(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleAsk()}
            className="flex-grow px-4 py-2 rounded bg-zinc-700 text-white"
          />
          <button
            onClick={handleAsk}
            className="bg-purple-600 hover:bg-purple-700 px-4 py-2 rounded"
          >
            Ask
          </button>
        </div>
      </div>
    </div>
  );
};

export default Page;
