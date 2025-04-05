import prettier from "prettier/standalone";
import parserBabel from "prettier/parser-babel";
import parserHtml from "prettier/parser-html";
import parserCss from "prettier/parser-postcss";
import parserMarkdown from "prettier/parser-markdown";
import parserYaml from "prettier/parser-yaml";
import parserTypescript from "prettier/parser-typescript";

import yaml from 'js-yaml';
import { XMLParser, XMLBuilder } from 'fast-xml-parser';
import Papa from 'papaparse';

interface ParserOptions {
  [key: string]: {
    parser: string;
    plugins: any[];
    additionalOptions?: object;
  };
}

export type DataFormat = 'json' | 'xml' | 'yaml' | 'csv';

interface ValidationResult {
  isValid: boolean;
  message?: string;
  lineNumber?: number;
  detailedError?: string;
}

interface ConversionResult {
  data: string;
  error?: string;
}

const parserOptions: ParserOptions = {
  javascript: {
    parser: "babel",
    plugins: [parserBabel],
    additionalOptions: {
      semi: true,
      singleQuote: false,
    },
  },
  typescript: {
    parser: "typescript",
    plugins: [parserTypescript],
    additionalOptions: {
      semi: true,
      singleQuote: false,
    },
  },
  html: {
    parser: "html",
    plugins: [parserHtml],
  },
  css: {
    parser: "css",
    plugins: [parserCss],
  },
  json: {
    parser: "json",
    plugins: [parserBabel],
  },
  markdown: {
    parser: "markdown",
    plugins: [parserMarkdown],
  },
  yaml: {
    parser: "yaml",
    plugins: [parserYaml],
  },
  python: {
    parser: "python",
    plugins: [parserBabel], // Note: You'll need to add proper Python parser
  },
  java: {
    parser: "java",
    plugins: [parserBabel], // Note: You'll need to add proper Java parser
  },
};

export async function validateFormat(input: string, format: DataFormat): Promise<ValidationResult> {
  try {
    switch(format) {
      case 'json':
        try {
          JSON.parse(input);
          const formattedJson = JSON.stringify(JSON.parse(input), null, 2);
          return { isValid: true, message: formattedJson };
        } catch (e) {
          const error = e as SyntaxError;
          const match = error.message.match(/at position (\d+)/);
          let lineNumber = 1;
          if (match) {
            const position = parseInt(match[1]);
            lineNumber = input.substring(0, position).split('\n').length;
          }
          return { 
            isValid: false, 
            message: error.message,
            lineNumber,
            detailedError: `Error at line ${lineNumber}: ${error.message}`
          };
        }
      
      case 'yaml':
        try {
          yaml.load(input);
          return { isValid: true, message: input };
        } catch (e) {
          const error = e as yaml.YAMLException;
          return { 
            isValid: false, 
            message: error.message,
            lineNumber: error.mark?.line ? error.mark.line + 1 : undefined,
            detailedError: `Error at line ${error.mark?.line ? error.mark.line + 1 : 'unknown'}: ${error.reason}`
          };
        }
      
      case 'xml':
        try {
          const parser = new XMLParser({ 
            ignoreAttributes: false,
            attributeNamePrefix: "@_"
          });
          parser.parse(input);
          return { isValid: true, message: input };
        } catch (e) {
          const error = e as Error;
          // Extract line number from XML parser error message if available
          const lineMatch = error.message.match(/Line: (\d+)/);
          const lineNumber = lineMatch ? parseInt(lineMatch[1]) : undefined;
          return { 
            isValid: false, 
            message: error.message,
            lineNumber,
            detailedError: `Error ${lineNumber ? `at line ${lineNumber}` : ''}: ${error.message}`
          };
        }
      
      case 'csv':
        const result = Papa.parse(input, { header: true });
        if (result.errors.length > 0) {
          const error = result.errors[0];
          return { 
            isValid: false, 
            message: error.message,
            lineNumber: error.row ? error.row + 1 : undefined,
            detailedError: `Error at line ${error.row ? error.row + 1 : 'unknown'}: ${error.message}`
          };
        }
        return { isValid: true, message: input };
      
      default:
        return { isValid: false, message: 'Unsupported format' };
    }
  } catch (error) {
    return { 
      isValid: false, 
      message: error instanceof Error ? error.message : 'Invalid format'
    };
  }
}

// Conversion functions
export async function convertFormat(input: string, inputFormat: DataFormat, outputFormat: DataFormat): Promise<ConversionResult> {
  try {
    // If formats are the same, return the input
    if (inputFormat === outputFormat) {
      return { data: input };
    }

    // Parse the input based on its format
    let parsedData: any;
    switch(inputFormat) {
      case 'json':
        parsedData = JSON.parse(input);
        break;
      
      case 'yaml':
        parsedData = yaml.load(input);
        break;
      
      case 'xml':
        const parser = new XMLParser({ 
          ignoreAttributes: false,
          attributeNamePrefix: "@_"
        });
        parsedData = parser.parse(input);
        break;
      
      case 'csv':
        const result = Papa.parse(input, { header: true });
        if (result.errors.length > 0) {
          throw new Error(result.errors[0].message);
        }
        parsedData = result.data;
        break;
      
      default:
        throw new Error('Unsupported input format');
    }

    // Convert to the output format
    let output: string = '';
    switch(outputFormat) {
      case 'json':
        // Use manual JSON formatting instead of prettier
        output = JSON.stringify(parsedData, null, 2);
        break;
      
      case 'yaml':
        output = yaml.dump(parsedData);
        break;
      
      case 'xml':
        const builder = new XMLBuilder({ 
          ignoreAttributes: false,
          attributeNamePrefix: "@_",
          format: true
        });
        output = builder.build(parsedData);
        break;
      
      case 'csv':
        if (Array.isArray(parsedData)) {
          output = Papa.unparse(parsedData);
        } else if (typeof parsedData === 'object' && parsedData !== null) {
          output = Papa.unparse([parsedData]);
        } else {
          throw new Error('Cannot convert to CSV. Input must be an object or array of objects.');
        }
        break;
      
      default:
        throw new Error('Unsupported output format');
    }

    return { data: output };
  } catch (error) {
    throw error instanceof Error 
      ? error 
      : new Error('An error occurred during conversion');
  }
}

export async function formatCode(
  code: string,
  language: string
): Promise<string> {
  try {
    const options = parserOptions[language];
    if (!options) {
      throw new Error(`Unsupported language: ${language}`);
    }

    const formattedCode = await prettier.format(code, {
      parser: options.parser,
      plugins: options.plugins,
      semi: true,
      singleQuote: false,
      tabWidth: 2,
      trailingComma: "es5",
      printWidth: 80,
      ...options.additionalOptions,
    });

    return formattedCode;
  } catch (error: any) {
    console.error("Error formatting code:", error);
    throw new Error(
      error.message || "An error occurred while formatting the code"
    );
  }
}
