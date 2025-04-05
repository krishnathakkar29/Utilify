"use client"

import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import {
  Code,
  Copy,
  Download,
  Save,
  Share2,
} from "lucide-react";
import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { useCompiler } from "@/context/compiler-context";

const HelperHeader = () => {
  const { currentLanguage, fullCode, updateCurrentLanguage } = useCompiler();
  const [title, setTitle] = useState<string>("My Code");

  const handleDownloadCode = () => {
    if (fullCode.html === "" && fullCode.css === "" && fullCode.javascript === "") {
      toast.error("Error: Code is Empty!");
      return;
    }

    const htmlCode = new Blob([fullCode.html], { type: "text/html" });
    const cssCode = new Blob([fullCode.css], { type: "text/css" });
    const javascriptCode = new Blob([fullCode.javascript], { type: "text/javascript" });

    const htmlLink = document.createElement("a");
    const cssLink = document.createElement("a");
    const javascriptLink = document.createElement("a");

    htmlLink.href = URL.createObjectURL(htmlCode);
    htmlLink.download = "index.html";
    document.body.appendChild(htmlLink);

    cssLink.href = URL.createObjectURL(cssCode);
    cssLink.download = "style.css";
    document.body.appendChild(cssLink);

    javascriptLink.href = URL.createObjectURL(javascriptCode);
    javascriptLink.download = "script.js";
    document.body.appendChild(javascriptLink);

    if (fullCode.html !== "") {
      htmlLink.click();
    }
    if (fullCode.css !== "") {
      cssLink.click();
    }
    if (fullCode.javascript !== "") {
      javascriptLink.click();
    }

    document.body.removeChild(htmlLink);
    document.body.removeChild(cssLink);
    document.body.removeChild(javascriptLink);

    toast.success("Code Downloaded Successfully");
  };

  return (
    <div className="helper-header h-[50px] bg-background border-b border-border/40 text-foreground p-2 flex items-center justify-between">
      <div className="btn-container flex gap-2">
        {/* <Dialog>
          <DialogTrigger asChild>
            <Button variant="default" className="gap-1.5">
              <Save size={16} /> Save
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle className="flex gap-2 items-center">
                <Code className="h-5 w-5" /> Save Your Code
              </DialogTitle>
              <DialogDescription className="flex flex-col gap-4 pt-4">
                <div className="flex gap-2">
                  <Input
                    className="flex-1"
                    placeholder="Type your code title"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                  />
                  <Button>
                    Save
                  </Button>
                </div>
              </DialogDescription>
            </DialogHeader>
          </DialogContent>
        </Dialog> */}

        <Button variant="outline" size="icon" onClick={handleDownloadCode}>
            
          <Download size={16} />
        </Button>

        {/* <Dialog>
          <DialogTrigger asChild>
            <Button variant="outline" size="icon">
              <Share2 size={16} />
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle className="flex gap-2 items-center">
                <Code className="h-5 w-5" /> Share your Code
              </DialogTitle>
              <DialogDescription className="flex flex-col gap-4 pt-4">
                <div className="flex gap-2">
                  <Input
                    readOnly
                    value={window.location.href}
                  />
                  <Button variant="outline" size="icon" onClick={() => {
                    navigator.clipboard.writeText(window.location.href);
                    toast.success("URL Copied");
                  }}>
                    <Copy size={16} />
                  </Button>
                </div>
                <p className="text-center text-sm text-muted-foreground">Share this URL to collaborate</p>
              </DialogDescription>
            </DialogHeader>
          </DialogContent>
        </Dialog> */}
      </div>

      <div className="tab-switcher flex items-center gap-2">
        <span className="text-sm">Language:</span>
        <Select
          value={currentLanguage}
          onValueChange={(value) => updateCurrentLanguage(value as "html" | "css" | "javascript")}
        >
          <SelectTrigger className="w-[130px] bg-background border-border/40 focus-visible:ring-1">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="html">HTML</SelectItem>
            <SelectItem value="css">CSS</SelectItem>
            <SelectItem value="javascript">JavaScript</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
};

export default HelperHeader;