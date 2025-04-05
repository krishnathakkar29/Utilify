"use client";
import { useState } from "react";
import {
  ResizableHandle,
  ResizablePanel,
  ResizablePanelGroup,
} from "@/components/ui/resizable";
import { useCompiler } from "@/context/compiler-context";
import CodeEditor from "./code-editor";
import RenderCode from "./render-code";
import HelperHeader from "./helper-header";
function CodeCompiler() {
    const { fullCode } = useCompiler();
  
    return (
      <div className="h-[calc(100vh-80px)] w-full overflow-hidden rounded-lg border border-border/40 bg-background shadow-lg">
        <ResizablePanelGroup direction="horizontal" className="h-full rounded-lg">
          <ResizablePanel
            className="h-full min-w-[350px]"
            defaultSize={50}
          >
            <HelperHeader />
            <CodeEditor />
          </ResizablePanel>
  
          <ResizableHandle withHandle />
  
          <ResizablePanel
            className="h-full min-w-[350px]"
            defaultSize={50}
          >
            <RenderCode />
          </ResizablePanel>
        </ResizablePanelGroup>
      </div>
    );
  };

export default CodeCompiler