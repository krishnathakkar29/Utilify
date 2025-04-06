"use client";

import React, { createContext, useContext, useState, ReactNode } from "react";

export type ToolCategory =
  | "Text Formatter"
  | "CSV & Excel Tools"
  | "API Tools"
  | "Image & Graphic Converters"
  | "Code Formatter"
  | "Password Generator"
  | "Random Number Generator"
  | "Network Utilities"
  | "Other";

export type Status = "In Progress" | "In Queue";

export interface FeatureRequest {
  id: string;
  title: string;
  description: string;
  category: ToolCategory;
  status: Status;
  createdAt: Date;
}

interface FeatureRequestContextType {
  requests: FeatureRequest[];
  addRequest: (
    title: string,
    description: string,
    category: ToolCategory
  ) => void;
}

const FeatureRequestContext = createContext<
  FeatureRequestContextType | undefined
>(undefined);

export const useFeatureRequests = () => {
  const context = useContext(FeatureRequestContext);
  if (!context) {
    throw new Error(
      "useFeatureRequests must be used within a FeatureRequestProvider"
    );
  }
  return context;
};

export const FeatureRequestProvider: React.FC<{ children: ReactNode }> = ({
  children,
}) => {
  const [requests, setRequests] = useState<FeatureRequest[]>([]);

  const addRequest = (
    title: string,
    description: string,
    category: ToolCategory
  ) => {
    const newRequest: FeatureRequest = {
      id: crypto.randomUUID(),
      title,
      description,
      category,
      // Randomly assign a status
      status: Math.random() > 0.5 ? "In Progress" : "In Queue",
      createdAt: new Date(),
    };

    setRequests((prev) => [...prev, newRequest]);
  };

  return (
    <FeatureRequestContext.Provider value={{ requests, addRequest }}>
      {children}
    </FeatureRequestContext.Provider>
  );
};
