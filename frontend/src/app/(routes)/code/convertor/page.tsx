"use client";

import React, { useState, useEffect } from "react";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader } from "@/components/ui/card";

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

import { validateFormat, convertFormat } from "@/services/formatter";
import { Copy, Check, Wand2 } from "lucide-react";
import { toast } from "sonner";

type DataFormat = "json" | "xml" | "yaml" | "csv";

interface ValidationError {
  lineNumber?: number;
  detailedError?: string;
}

function page() {
    const [inputText, setInputText] = useState("");
    const [outputText, setOutputText] = useState("");
    const [inputFormat, setInputFormat] = useState<DataFormat>("json");
    const [outputFormat, setOutputFormat] = useState<DataFormat>("yaml");
    const [isValidating, setIsValidating] = useState(false);
    const [isConverting, setIsConverting] = useState(false);
    const [validationStatus, setValidationStatus] = useState<"valid" | "invalid" | null>(null);
    const [copyStatus, setCopyStatus] = useState<"idle" | "copied">("idle");
    const [validationError, setValidationError] = useState<ValidationError | null>(null);
  
    // Reset output when input changes
    useEffect(() => {
      setOutputText("");
      setValidationStatus(null);
      setValidationError(null);
    }, [inputText]);
  
    // Reset output format when input format changes
    useEffect(() => {
      setOutputFormat((prev) => (prev === inputFormat ? "yaml" : prev));
    }, [inputFormat]);
  
    const handleValidate = async () => {
      if (!inputText.trim()) {
        toast.error("Please enter some content to validate.");
        return;
      }
    
      setIsValidating(true);
      setValidationError(null);
      try {
        const result = await validateFormat(inputText, inputFormat);
        setValidationStatus(result.isValid ? "valid" : "invalid");
        setOutputText(result.message || "");
        
        if (!result.isValid && (result.lineNumber || result.detailedError)) {
          setValidationError({
            lineNumber: result.lineNumber,
            detailedError: result.detailedError
          });
          toast.error(result.detailedError || "Invalid format");
        } else {
          toast.success("Valid format!");
        }
      } catch (error) {
        setValidationStatus("invalid");
        toast.error(`Validation failed: ${error instanceof Error ? error.message : "An unknown error occurred"}`);
      } finally {
        setIsValidating(false);
      }
    };
  
    const handleConvert = async () => {
      if (!inputText.trim()) {
        toast.error("Please enter some content to convert.");
        return;
      }
  
      if (inputFormat === outputFormat) {
        toast.error("Input and output formats cannot be the same.");
        return;
      }
  
      setIsConverting(true);
      try {
        const result = await convertFormat(inputText, inputFormat, outputFormat);
        setOutputText(result.data);
        toast.success(`Converted to ${outputFormat.toUpperCase()} format!`);
      } catch (error) {
        console.log(error)
        toast.error(`Conversion failed: ${error instanceof Error ? error.message : "An unknown error occured"}`);
      } finally {
        setIsConverting(false);
      }
    };
  
    const copyToClipboard = async (text: string) => {
      try {
        await navigator.clipboard.writeText(text);
        setCopyStatus("copied");
        toast.success("Copied to clipboard!");
        setTimeout(() => setCopyStatus("idle"), 2000);
      } catch (err) {
        toast.error("Failed to copy to clipboard.");
      }
    };
  
    return (
      <div>

          <h2 className="text-2xl font-bold text-center mb-2">Text Format Validator & Converter</h2>
          <p className="text-muted-foreground text-center max-w-2xl mx-auto">
            Validate and convert between JSON, XML, YAML, and CSV formats with ease.
          </p>
        
        <Tabs defaultValue="validate" className="w-full">
          <TabsList className="grid w-full max-w-md grid-cols-2 mx-auto mb-6">
            <TabsTrigger value="validate">Validate</TabsTrigger>
            <TabsTrigger value="convert">Convert</TabsTrigger>
          </TabsList>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Input Panel */}
            <Card className="min-h-[60vh]">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div className="flex flex-col space-y-1.5">
                  <h3 className="font-semibold leading-none tracking-tight">Input</h3>
                  <p className="text-sm text-muted-foreground">Enter your text to validate or convert</p>
                </div>
                <div className="flex items-center space-x-2">
                  <Select value={inputFormat} onValueChange={(value: DataFormat) => setInputFormat(value)}>
                    <SelectTrigger className="w-[130px]">
                      <SelectValue placeholder="Format" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="json">JSON</SelectItem>
                      <SelectItem value="xml">XML</SelectItem>
                      <SelectItem value="yaml">YAML</SelectItem>
                      <SelectItem value="csv">CSV</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={() => copyToClipboard(inputText)}
                    disabled={!inputText}
                    title="Copy to clipboard"
                  >
                    <Copy className="h-4 w-4" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <Textarea 
                  className="min-h-[50vh] font-mono text-sm"
                  placeholder={`Enter your ${inputFormat.toUpperCase()} here...`}
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value)}
                />
              </CardContent>
            </Card>
            
            {/* Output Panel */}
            <Card className="min-h-[60vh]">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div className="flex flex-col space-y-1.5">
                  <h3 className="font-semibold leading-none tracking-tight">Output</h3>
                  <TabsContent value="validate">
                    <p className="text-sm text-muted-foreground">Validation results</p>
                  </TabsContent>
                  <TabsContent value="convert">
                    <p className="text-sm text-muted-foreground">Converted output</p>
                  </TabsContent>
                </div>
                <div className="flex items-center space-x-2">
                  <TabsContent value="validate" className="mt-0">
                    {validationStatus && (
                      <div className={`px-2 py-1 rounded text-xs ${
                        validationStatus === 'valid' 
                          ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200' 
                          : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
                      }`}>
                        {validationStatus === 'valid' ? 'Valid' : 'Invalid'}
                      </div>
                    )}
                  </TabsContent>
                  <TabsContent value="convert" className="mt-0">
                    <Select value={outputFormat} onValueChange={(value: DataFormat) => setOutputFormat(value)}>
                      <SelectTrigger className="w-[130px]">
                        <SelectValue placeholder="Format" />
                      </SelectTrigger>
                      <SelectContent>
                        {inputFormat !== "json" && <SelectItem value="json">JSON</SelectItem>}
                        {inputFormat !== "xml" && <SelectItem value="xml">XML</SelectItem>}
                        {inputFormat !== "yaml" && <SelectItem value="yaml">YAML</SelectItem>}
                        {inputFormat !== "csv" && <SelectItem value="csv">CSV</SelectItem>}
                      </SelectContent>
                    </Select>
                  </TabsContent>
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={() => copyToClipboard(outputText)}
                    disabled={!outputText}
                    title="Copy to clipboard"
                  >
                    {copyStatus === "copied" ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <TabsContent value="validate" className="mt-0">
                  {validationError && !outputText && (
                    <div className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md">
                      {validationError.lineNumber && (
                        <p className="text-sm font-medium text-red-800 dark:text-red-200">
                          Error at line: {validationError.lineNumber}
                        </p>
                      )}
                      {validationError.detailedError && (
                        <p className="text-sm text-red-600 dark:text-red-300 mt-1">
                          {validationError.detailedError}
                        </p>
                      )}
                    </div>
                  )}
                  <Textarea 
                    className="min-h-[50vh] font-mono text-sm"
                    placeholder="Validation results will appear here..."
                    value={outputText}
                    readOnly
                  />
                </TabsContent>
                <TabsContent value="convert" className="mt-0">
                  <Textarea 
                    className="min-h-[50vh] font-mono text-sm"
                    placeholder="Converted output will appear here..."
                    value={outputText}
                    readOnly
                  />
                </TabsContent>
              </CardContent>
            </Card>
          </div>
          
          {/* Action Buttons */}
          <div className="flex justify-center mt-6 space-x-4">
            <TabsContent value="validate" className="mt-0">
              <Button 
                onClick={handleValidate}
                disabled={isValidating || !inputText}
                className="px-8"
              >
                {isValidating ? "Validating..." : "Validate"}
                <Wand2 className="w-4 h-4 ml-2" />
              </Button>
            </TabsContent>
            <TabsContent value="convert" className="mt-0">
              <Button 
                onClick={handleConvert}
                disabled={isConverting || !inputText || inputFormat === outputFormat}
                className="px-8"
              >
                {isConverting ? "Converting..." : "Convert"}
                <Wand2 className="w-4 h-4 ml-2" />
              </Button>
            </TabsContent>
          </div>
        </Tabs>
      </div>
    );
  };

export default page;