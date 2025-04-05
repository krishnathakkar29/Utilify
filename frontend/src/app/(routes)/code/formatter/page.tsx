"use client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { formatCode } from "@/services/formatter";
import Editor from "@monaco-editor/react";
import { Copy, Wand2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";

const languages = [
  { value: "javascript", label: "JavaScript" },
  { value: "typescript", label: "TypeScript" },
  { value: "html", label: "HTML" },
  { value: "css", label: "CSS" },
  { value: "json", label: "JSON" },
  { value: "markdown", label: "Markdown" },
  { value: "yaml", label: "YAML" },
  { value: "python", label: "Python" },
  { value: "java", label: "Java" },
];

function FormatterPage() {
  const [language, setLanguage] = useState("javascript");
  const [inputCode, setInputCode] = useState("");
  const [outputCode, setOutputCode] = useState("");
  const [isFormatting, setIsFormatting] = useState(false);
  const [editorOptions, setEditorOptions] = useState({
    minimap: { enabled: false },
    fontSize: 14,
    lineNumbers: "on" as const,
    roundedSelection: false,
    scrollBeyondLastLine: false,
    readOnly: false,
    theme: "vs-dark",
  });

  const handleEditorChange = (value: string | undefined) => {
    setInputCode(value || "");
  };

  const handleFormat = async () => {
    if (!inputCode.trim()) {
      toast.error("Please enter some code to format");
      return;
    }

    setIsFormatting(true);
    try {
      const formatted = await formatCode(inputCode, language);
      setOutputCode(formatted);
      toast.success("Code formatted successfully!");
    } catch (error: any) {
      console.error("Formatting error:", error);
      toast.error(error.message || "Failed to format code");
    } finally {
      setIsFormatting(false);
    }
  };

  const copyToClipboard = () => {
    if (!outputCode) {
      toast.error("No formatted code to copy");
      return;
    }

    navigator.clipboard
      .writeText(outputCode)
      .then(() => toast.success("Copied to clipboard!"))
      .catch(() => toast.error("Failed to copy"));
  };

  const handleEditorBeforeMount = (monaco: typeof import("monaco-editor")) => {
    monaco.editor.defineTheme("dark-theme", {
      base: "vs-dark",
      inherit: true,
      rules: [],
      colors: {},
    });
  };

  const handleEditorDidMount = (editor: any, monaco: any) => {
    monaco.editor.setTheme("vs-dark");
  };

  return (
    <div className="space-y-4 p-4 max-w-[1600px] mx-auto">
      <div className="mb-6">
        <h2 className="text-3xl font-bold text-center bg-gradient-to-r from-blue-400 to-purple-600 bg-clip-text text-transparent">
          Code Formatter
        </h2>
        <p className="text-muted-foreground text-center mt-2">
          Format your code with intelligent defaults
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="h-full">
          <CardHeader className="pb-3">
            <div className="flex justify-between items-center">
              <CardTitle>Input Code</CardTitle>
              <div className="flex gap-2">
                <Select value={language} onValueChange={setLanguage}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Select language" />
                  </SelectTrigger>
                  <SelectContent>
                    {languages.map((lang) => (
                      <SelectItem key={lang.value} value={lang.value}>
                        {lang.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="min-h-[500px] border rounded-md overflow-hidden">
              <Editor
                height="500px"
                language={language}
                value={inputCode}
                onChange={handleEditorChange}
                options={editorOptions}
              />
            </div>
            <Button
              onClick={handleFormat}
              className="mt-4 w-full"
              disabled={isFormatting || !inputCode.trim()}
            >
              <Wand2
                className={`mr-2 h-4 w-4 ${isFormatting ? "animate-spin" : ""}`}
              />
              {isFormatting ? "Formatting..." : "Format Code"}
            </Button>
          </CardContent>
        </Card>

        <Card className="h-full">
          <CardHeader className="pb-3">
            <div className="flex justify-between items-center">
              <CardTitle>Formatted Code</CardTitle>
              <Button
                variant="outline"
                size="sm"
                onClick={copyToClipboard}
                disabled={!outputCode}
              >
                <Copy className="mr-2 h-4 w-4" />
                Copy
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="min-h-[500px] border rounded-md overflow-hidden">
              <Editor
                height="500px"
                language={language}
                value={outputCode}
                options={{ ...editorOptions, readOnly: true }}
                beforeMount={handleEditorBeforeMount}
                onMount={handleEditorDidMount}
                theme="vs-dark"
              />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

export default FormatterPage;
