"use client";
import { createContext, useContext, useState } from "react";

interface FullCode {
  html: string;
  css: string;
  javascript: string;
}

interface CompilerContextType {
  currentLanguage: "html" | "css" | "javascript";
  fullCode: FullCode;
  isOwner: boolean;
  updateCurrentLanguage: (language: "html" | "css" | "javascript") => void;
  updateCodeValue: (value: string) => void;
  updateFullCode: (code: FullCode) => void;
}

const initialState: FullCode = {
  html: `
<html lang="en">
  <body>
    <div class="container">
        <h1>Welcome to the Color Changer</h1>
        <button id="colorButton">Change Background Color</button>
    </div>
    <script src="script.js"></script>
  </body>
</html>

    `,
    css: `
    body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background-color: #f0f0f0;
  }
  
  .container {
      text-align: center;
  }
  
  button {
      padding: 10px 20px;
      font-size: 16px;
      cursor: pointer;
      background-color: #007BFF;
      color: white;
      border: none;
      border-radius: 5px;
  }
  
  button:hover {
      background-color: #0056b3;
  }
    `,
    javascript: `
    document.getElementById('colorButton').addEventListener('click', function() {
      const colors = ['#FF5733', '#33FF57', '#3357FF', '#F333FF', '#33FFF3'];
      const randomColor = colors[Math.floor(Math.random() * colors.length)];
      document.body.style.backgroundColor = randomColor;
  });
    `,
};
const CompilerContext = createContext<CompilerContextType | undefined>(
  undefined)


export function CompilerProvider({children}: {
  children: React.ReactNode;
}){
  const [currentLanguage, setCurrentLanguage] = useState<"html" | "css" | "javascript">("html");
  const [fullCode, setFullCode] = useState<FullCode>(initialState);
  const [isOwner, setIsOwner] = useState(false);

  const updateCurrentLanguage = (language: "html" | "css" | "javascript") => {
    setCurrentLanguage(language);
  };

  const updateCodeValue = (value: string) => {
    setFullCode((prevState) => ({
      ...prevState,
      [currentLanguage]: value,
    }));
  };

  const updateFullCode = (code: FullCode) => {
    setFullCode(code);
  };

  return (
    <CompilerContext.Provider
      value={{
        currentLanguage,
        fullCode,
        isOwner,
        updateCurrentLanguage,
        updateCodeValue,
        updateFullCode,
      }}
    >
      {children}
    </CompilerContext.Provider>
  );
}

export function useCompiler() {
  const context = useContext(CompilerContext);
  if (context === undefined) {
    throw new Error("useCompiler must be used within a CompilerProvider");
  }
  return context;
}