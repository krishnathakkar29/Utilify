"use client";

import React, { useState } from "react";

function CodeCompiler() {
  const [output, setOutput] = useState("");

  const handleCompile = () => {
    // Logic to compile code and set output
    setOutput("Compiled output here");
  };

  return (
    <div className="code-compiler">
      <button onClick={handleCompile}>Compile</button>
      <iframe
        title="output"
        sandbox="allow-scripts"
        frameBorder="0"
        src={output ? output : "about:blank"} // Use about:blank instead of empty string
        className="w-full h-full"
      />
    </div>
  );
}

export default CodeCompiler;