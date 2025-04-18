"use client";
import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

import { FileIcon, MergeIcon, Scissors, RotateCw } from "lucide-react";
import PDFMerge from "@/components/pages/pdf/pdf-merge";
import PDFRotate from "@/components/pages/pdf/pdf-rotate";
import PDFSplit from "@/components/pages/pdf/pdf-split";

const PDFManipulator = () => {
  const [activeTab, setActiveTab] = useState("merge");

  const tabs = [
    { id: "merge", label: "Merge PDFs", icon: MergeIcon },
    { id: "split", label: "Split PDF", icon: Scissors },
    { id: "rotate", label: "Rotate PDF", icon: RotateCw },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">PDF Tools</h1>
        <p className="text-muted-foreground">
          Edit and manipulate PDF files with our intuitive tools
        </p>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-center space-x-2">
            <FileIcon size={20} className="text-accent" />
            <CardTitle>PDF Manipulator</CardTitle>
          </div>
          <CardDescription>
            Merge multiple PDFs, split a single PDF, or rotate pages according
            to your needs.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs
            defaultValue="merge"
            value={activeTab}
            onValueChange={setActiveTab}
            className="w-full"
          >
            <TabsList className="grid grid-cols-3 mb-8">
              {tabs.map((tab) => (
                <TabsTrigger
                  key={tab.id}
                  value={tab.id}
                  className="flex items-center space-x-2"
                >
                  <tab.icon size={16} />
                  <span>{tab.label}</span>
                </TabsTrigger>
              ))}
            </TabsList>
            <TabsContent value="merge">
              <PDFMerge />
            </TabsContent>
            <TabsContent value="split">
              <PDFSplit />
            </TabsContent>
            <TabsContent value="rotate">
              <PDFRotate />
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
};

export default PDFManipulator;
