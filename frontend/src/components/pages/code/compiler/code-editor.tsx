"use client";

import CodeMirror from "@uiw/react-codemirror";
import { useCallback } from "react";
import { loadLanguage } from "@uiw/codemirror-extensions-langs";
import { draculaInit } from "@uiw/codemirror-theme-dracula";
import { tags as t } from "@lezer/highlight";
import { useCompiler } from "@/context/compiler-context";

const CodeEditor = () => {
  const { currentLanguage, fullCode, updateCodeValue } = useCompiler();

  const onChange = useCallback((value: string) => {
    updateCodeValue(value);
  }, [updateCodeValue]);

  return (
    <CodeMirror
      value={fullCode[currentLanguage]}
      height="calc(100vh - 80px - 50px)"
      extensions={[loadLanguage(currentLanguage)!]}
      onChange={onChange}
      theme={draculaInit({
        settings: {
          caret: "#c6c6c6",
          fontFamily: "monospace",
        },
        styles: [{ tag: t.comment, color: "#6272a4" }],
      })}
      className="text-sm"
    />
  );
};

export default CodeEditor;