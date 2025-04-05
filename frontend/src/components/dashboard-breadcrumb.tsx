"use client";
import React from "react";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

export default function DashboardBreadCrumb() {
  const pathname = usePathname();
  const path = pathname.split("/").filter(Boolean);
  const pathToTitle: Record<string, string> = {
    dashboard: "Dashboard",
    documents: "Documents",
    "csv-excel": "CSV & Excel Functions",
    "file-hosting": "File Hosting",
    "document-summarization": "Document Summarization",
    "query-document": "Query Document",
    work: "Work",
    "form-builder": "Form Builder",
    "bulk-email": "Bulk Email Sender",
    "qr-generator": "QR Generator",
    "schedule-meetings": "Schedule Meetings",
    "code-conquer": "Code And Conquer",
    "code-formatter": "Code Formatter",
    "web-compiler": "Web Compiler",
    "json-xml-validator": "JSON XML Validator",
    "api-tools": "Api Tools",
    "markdown-editor": "Markdown Editor",
    security: "Security & Network",
    "password-generator": "Password Generator",
    "password-checker": "Password Strength Checker",
    "random-number": "Random Number Generator",
    "dns-lookup": "DNS / IP Lookup",
    "aes-encryptor": "AES Encryptor",
    tools: "Everyday Tools",
    "unit-converter": "Unit Converter",
    "currency-converter": "Currency Converter",
    "world-clock": "World Clock",
    "timer-counter": "Timer & Counter",
    notes: "Notes",
    "color-palette": "Color Pallete Generator",
  };
  function getPath(i: number): string {
    return "/" + path.slice(0, i + 1).join("/");
  }
  function isActive(i: number): boolean {
    return getPath(i) === pathname;
  }
  return (
    <Breadcrumb>
      <BreadcrumbList>
        {path.map((p, i) => (
          <React.Fragment key={i}>
            <BreadcrumbItem
              className={cn(
                isActive(i) && "text-white",
                !isActive(i) && i < path.length - 1 && "hidden md:block"
              )}
            >
              <BreadcrumbLink href={getPath(i)}>
                {pathToTitle[p]}
              </BreadcrumbLink>
            </BreadcrumbItem>
            {i !== path.length - 1 && <BreadcrumbSeparator />}
          </React.Fragment>
        ))}
      </BreadcrumbList>
    </Breadcrumb>
  );
}
