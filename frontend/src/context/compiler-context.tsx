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
  html: "",
  css: "",
  javascript: "",
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