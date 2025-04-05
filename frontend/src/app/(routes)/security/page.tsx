// "use client";
// import React from "react";
// import RainText from "@/components/ui/matrix-code"
// function page() {
//   return (<>
//   <RainText fontSize={20}
//           color="#00ff00"
//           characters="01"
//           fadeOpacity={0.1}
//           speed={1.0}/>

//             <div className="relative min-h-screen">
//               <h1>
//                 Matrix Code
//               </h1>
//               <h2>helloooo</h2>
//               </div>
//   </>);
// }

// export default page;

"use client";

import React, { useEffect, useRef, useState } from "react";
import { toast, Toaster } from "sonner"; 
import { BACKEND_FLASK_URL } from "../../../config/config";

const Page: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  const [prompt, setPrompt] = useState("");
  const [input, setInput] = useState("");
  const [result, setResult] = useState("");
  const [extraInput, setExtraInput] = useState({ min: "", max: "" });
  const [mode, setMode] = useState<null | string>(null);

  const fontSize = 20;
  const color = "#00ff00";
  const characters = "01";
  const fadeOpacity = 0.1;
  const speed = 1;

  const getSidebarWidth = () => {
    const side = Array.from(document.querySelectorAll("*")).find(
      (el) =>
        el.textContent?.includes("Utilify") &&
        el instanceof HTMLElement &&
        el.offsetHeight > 100 &&
        getComputedStyle(el).position === "fixed"
    ) as HTMLElement | undefined;

    return side?.offsetWidth || 0;
  };

  const updateFloatingPanelPosition = () => {
    const panel = panelRef.current;
    if (!panel) return;

    const sidebarWidth = getSidebarWidth();
    const panelWidth = panel.offsetWidth;

    panel.style.left = `${sidebarWidth + (window.innerWidth - sidebarWidth) / 2}px`;
    panel.style.transform = "translateX(-50%) translateY(-50%)";
  };

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const resizeCanvas = () => {
      const sidebarWidth = getSidebarWidth();
      canvas.style.left = `${sidebarWidth}px`;
      canvas.width = window.innerWidth - sidebarWidth;
      canvas.height = window.innerHeight;
      updateFloatingPanelPosition();
    };

    resizeCanvas();
    window.addEventListener("resize", resizeCanvas);

    const chars = characters.split("");
    let drops: number[] = [];

    const draw = () => {
      ctx.fillStyle = `rgba(0, 0, 0, ${fadeOpacity})`;
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.fillStyle = color;
      ctx.font = `${fontSize}px monospace`;

      const columnCount = Math.floor(canvas.width / fontSize);
      if (drops.length !== columnCount) {
        drops = Array(columnCount)
          .fill(0)
          .map(() => Math.random() * -100);
      }

      for (let i = 0; i < drops.length; i++) {
        const char = chars[Math.floor(Math.random() * chars.length)];
        ctx.fillText(char, i * fontSize, drops[i] * fontSize);

        if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
          drops[i] = 0;
        }
        drops[i] += speed;
      }
    };

    const interval = setInterval(draw, 33 / speed);

    return () => {
      clearInterval(interval);
      window.removeEventListener("resize", resizeCanvas);
    };
  }, []);

  const handleAction = async () => {
    switch (mode) {
      case "generatePassword":
        try {
          const res = await fetch(`${BACKEND_FLASK_URL}/generate-password`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              length: Number(input),
              symbols: "true",
            }),
          });

          const data = await res.json();

          if (!res.ok) {
            setResult(`Error: ${data.error}`);
            return;
          }

          setResult(`Generated Password: ${data.password}`);
        } catch (error) {
          console.error(error);
          setResult("Something went wrong!");
        }
        break;

      case "checkStrength":
        try {
          const res = await fetch(`${BACKEND_FLASK_URL}/check-password`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ password: input }),
          });

          const data = await res.json();
          if (!res.ok) {
            setResult(`Error: ${data.error}`);
          } else {
            const { entropy, crack_time, strength_feedback } = data;
            setResult(
              `Password Strength Feedback:\n\nEntropy: ${entropy} bits\nEstimated Crack Time: ${crack_time}\nFeedback: ${strength_feedback}`
            );
          }
        } catch (err) {
          setResult(`Error: ${err}`);
        }
        break;

      case "randomNumber":
        const resultrand = Math.floor(
          Math.random() * (Number(extraInput.max) - Number(extraInput.min)) +
            Number(extraInput.min)
        );
        setResult(
          `Random number between ${extraInput.min}-${extraInput.max}: ${resultrand}`
        );
        break;

      case "generateUUID":
        try {
          const res = await fetch(`${BACKEND_FLASK_URL}/generate-uuids`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ num: parseInt(input || "0") }),
          });

          const data = await res.json();

          if (!res.ok) {
            setResult(`Error: ${data.error}`);
          } else {
            const uuidList = data.uuids.join("\n");
            setResult(`Generated ${data.uuids.length} UUID(s):\n\n${uuidList}`);
          }
        } catch (err) {
          setResult(`Error: ${err}`);
        }
        break;

      default:
        setResult("");
    }
  };

  return (
    <>
      
      <canvas
        ref={canvasRef}
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          height: "100%",
          zIndex: 0,
          pointerEvents: "none",
        }}
      />

      <div
        ref={panelRef}
        className="fixed top-1/2 z-10 bg-black/70 text-green-400 p-6 rounded-xl space-y-4 shadow-xl backdrop-blur-sm w-96"
        style={{
          transform: "translate(-50%, -50%)",
        }}
      >
        <div className="grid grid-cols-2 gap-3">
          <button
            onClick={() => {
              setMode("generatePassword");
              setPrompt("Enter password length");
              setInput("");
              setResult("");
            }}
            className="bg-green-700 hover:bg-green-800 px-3 py-2 rounded"
          >
            Generate Password
          </button>
          <button
            onClick={() => {
              setMode("checkStrength");
              setPrompt("Enter your password");
              setInput("");
              setResult("");
            }}
            className="bg-green-700 hover:bg-green-800 px-3 py-2 rounded"
          >
            Check Strength
          </button>
          <button
            onClick={() => {
              setMode("randomNumber");
              setPrompt("Enter range");
              setExtraInput({ min: "", max: "" });
              setResult("");
            }}
            className="bg-green-700 hover:bg-green-800 px-3 py-2 rounded"
          >
            Random Number
          </button>
          <button
            onClick={() => {
              setMode("generateUUID");
              setPrompt("How many UUIDs?");
              setInput("");
              setResult("");
            }}
            className="bg-green-700 hover:bg-green-800 px-3 py-2 rounded"
          >
            Generate UUID
          </button>
        </div>

        {mode && (
          <div className="space-y-3">
            <p className="text-sm text-green-300">{prompt}</p>

            {mode === "randomNumber" ? (
              <div className="flex gap-2">
                <input
                  placeholder="Min"
                  value={extraInput.min}
                  onChange={(e) =>
                    setExtraInput({ ...extraInput, min: e.target.value })
                  }
                  className="bg-black border border-green-600 px-3 py-1 rounded w-1/2"
                />
                <input
                  placeholder="Max"
                  value={extraInput.max}
                  onChange={(e) =>
                    setExtraInput({ ...extraInput, max: e.target.value })
                  }
                  className="bg-black border border-green-600 px-3 py-1 rounded w-1/2"
                />
              </div>
            ) : (
              <input
                type={mode === "checkStrength" ? "password" : "text"}
                value={input}
                onChange={(e) => setInput(e.target.value)}
                className="w-full bg-black border border-green-600 px-3 py-2 rounded"
              />
            )}

            <button
              onClick={handleAction}
              className="w-full bg-white text-green-800 py-2 rounded font-semibold"
            >
              Submit
            </button>

            {result && (
              <div className="relative">
                <div className="max-h-[50vh] overflow-y-auto border border-green-700 rounded p-2 pb-20">
                  <p className="text-2xl text-green-300 font-semibold whitespace-pre-line break-words">
                    {result}
                  </p>
                </div>

                <div className="absolute bottom-2 left-0 w-full px-2">
                  <button
                    onClick={() => {
                      navigator.clipboard.writeText(result);
                      toast.success("Copied to clipboard!");
                    }}
                    className="w-full bg-white text-green-800 py-2 rounded shadow-md"
                  >
                    Copy to Clipboard
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </>
  );
};

export default Page;
