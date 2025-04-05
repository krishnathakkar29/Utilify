"use client";

import React, { useState, useRef, useEffect, FormEvent } from "react";
import { RainbowButton } from "@/components/ui/rainbow-button";
import { BACKEND_FLASK_URL } from "@/config/config";

const Page: React.FC = () => {
  const [selectedButton, setSelectedButton] = useState<"qr" | "bar" | null>(null);
  const [inputText, setInputText] = useState<string>("");
  const [submittedText, setSubmittedText] = useState<string>("");
  const [barcodeImageUrl, setBarcodeImageUrl] = useState<string | null>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  const handleButtonClick = (button: "qr" | "bar") => {
    setSelectedButton(button);
    setInputText("");
    setSubmittedText("");
    setBarcodeImageUrl(null);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setSubmittedText(inputText);

    if (selectedButton === "bar") {
      const formData = new FormData();
      formData.append("text", inputText);
      try {
        const res = await fetch(`${BACKEND_FLASK_URL}/generate-barcode`, {
          method: "POST",
          body: formData,
        });

        if (!res.ok) {
          console.log("Failed to generate barcode");
          return;
        }

        const blob = await res.blob();
        const imageUrl = URL.createObjectURL(blob);
        setBarcodeImageUrl(imageUrl);
      } catch (error) {
        console.error("Barcode generation failed:", error);
      }
    }
  };

  const handleReset = () => {
    setSelectedButton(null);
    setInputText("");
    setSubmittedText("");
    setBarcodeImageUrl(null);
  };

  const getSidebarWidth = () => {
    const sidebar = Array.from(document.querySelectorAll("*")).find(
      (el) =>
        el.textContent?.includes("Utilify") &&
        el instanceof HTMLElement &&
        el.offsetHeight > 100 &&
        getComputedStyle(el).position === "fixed"
    ) as HTMLElement | undefined;

    return sidebar?.offsetWidth || 0;
  };

  const updatePanelPosition = () => {
    const panel = panelRef.current;
    if (!panel) return;

    const sidebarWidth = getSidebarWidth();
    panel.style.left = `${sidebarWidth + (window.innerWidth - sidebarWidth) / 2}px`;
    panel.style.transform = "translateX(-50%) translateY(-50%)";
  };

  useEffect(() => {
    updatePanelPosition();
    window.addEventListener("resize", updatePanelPosition);
    return () => window.removeEventListener("resize", updatePanelPosition);
  }, []);

  return (
    <div
      className="fixed top-1/2 z-10 p-6 w-full max-w-md bg-black/80 text-white rounded-xl shadow-xl backdrop-blur-md"
      ref={panelRef}
      style={{ transform: "translate(-50%, -50%)" }}
    >
      <h1 className="text-2xl font-bold mb-6 text-center">QR and Barcode Generator</h1>

      {!selectedButton && (
        <div className="flex justify-center gap-4">
          <RainbowButton
            onClick={() => handleButtonClick("qr")}
            className="bg-blue-500 text-black px-4 py-2 rounded hover:bg-blue-600"
          >
            Generate QR Code
          </RainbowButton>
          <RainbowButton
            onClick={() => handleButtonClick("bar")}
            className="bg-green-500 text-black px-4 py-2 rounded hover:bg-green-600"
          >
            Generate Bar Code
          </RainbowButton>
        </div>
      )}

      {selectedButton && !submittedText && (
        <form onSubmit={handleSubmit} className="mt-6 text-left">
          <label className="block mb-2 text-sm font-medium">
            Enter text or link to encode:
          </label>
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded mb-4 bg-black text-white"
            required
          />
          <button
            type="submit"
            className="w-full bg-purple-500 text-white px-4 py-2 rounded hover:bg-purple-600"
          >
            Submit
          </button>
        </form>
      )}

      {submittedText && selectedButton === "qr" && (
        <div className="mt-6 text-center space-y-4">
          <p className="break-words">
            You entered: <strong>{submittedText}</strong>
          </p>
          <img
            src={`https://api.qrserver.com/v1/create-qr-code/?data=${encodeURIComponent(
              submittedText
            )}&size=200x200`}
            alt="Generated QR"
            className="mx-auto"
          />
          <button
            onClick={handleReset}
            className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded"
          >
            Back
          </button>
        </div>
      )}

      {submittedText && selectedButton === "bar" && (
        <div className="mt-6 text-center space-y-4">
          <p className="break-words">
            You entered: <strong>{submittedText}</strong>
          </p>
          {barcodeImageUrl ? (
            <img
              src={barcodeImageUrl}
              alt="Generated Barcode"
              className="mx-auto max-w-full h-auto"
            />
          ) : (
            <p>Generating barcode...</p>
          )}
          <button
            onClick={handleReset}
            className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded"
          >
            Back
          </button>
        </div>
      )}
    </div>
  );
};

export default Page;
