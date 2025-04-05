"use client"

import { useCompiler } from '@/context/compiler-context';
import { useEffect, useState } from 'react';

const RenderCode = () => {
  const { fullCode } = useCompiler();
  const [iframeCode, setIframeCode] = useState('');

  useEffect(() => {
    const combinedCode = `
      <html>
        <head>
          <style>${fullCode.css}</style>
        </head>
        <body>${fullCode.html}</body>
        <script>${fullCode.javascript}</script>
      </html>
    `;
    
    setIframeCode(`data:text/html;charset=utf-8,${encodeURIComponent(combinedCode)}`);
  }, [fullCode]);

  return (
    <div className='h-full w-full'>
      <div className="bg-muted/30 px-4 py-2 font-mono text-sm text-muted-foreground">
        Result
      </div>
      <iframe 
        src={iframeCode} 
        className='h-[calc(100%-40px)] w-full bg-white dark:bg-zinc-900 border-none' 
        title="Code Preview"
        sandbox="allow-scripts allow-same-origin"
      />
    </div>
  );
};

export default RenderCode;