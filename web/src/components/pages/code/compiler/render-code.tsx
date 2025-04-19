"use client";

import { useCompiler } from "@/context/compiler-context";
import { useEffect, useState } from "react";

const RenderCode = () => {
  const { fullCode } = useCompiler();
  const [iframeCode, setIframeCode] = useState<string | null>(null);

  useEffect(() => {
    // Create and set the iframe src only after the component mounts
    const combinedCode = `
      <html>
        <head>
          <style>${fullCode.css}</style>
        </head>
        <body>${fullCode.html}</body>
        <script>${fullCode.javascript}</script>
      </html>
    `;

    // Wait for the next render cycle to set the iframe code
    const timerId = setTimeout(() => {
      setIframeCode(
        `data:text/html;charset=utf-8,${encodeURIComponent(combinedCode)}`
      );
    }, 0);

    return () => clearTimeout(timerId);
  }, [fullCode]);

  return (
    <div className="h-full w-full">
      <div className="bg-muted/30 px-4 py-2 font-mono text-sm text-muted-foreground">
        Result
      </div>
      {iframeCode ? (
        <iframe
          src={iframeCode}
          className="h-[calc(100%-40px)] w-full bg-white dark:bg-zinc-900 border-none"
          title="Code Preview"
          sandbox="allow-scripts allow-same-origin"
        />
      ) : (
        <div className="h-[calc(100%-40px)] w-full flex items-center justify-center bg-white dark:bg-zinc-900">
          <div className="text-muted-foreground">Loading preview...</div>
        </div>
      )}
    </div>
  );
};

export default RenderCode;
