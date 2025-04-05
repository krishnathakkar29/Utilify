"use client";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { TextGenerateEffect } from "@/components/ui/text-generate-effect";
import { networkAPI } from "@/services/api";
import { Activity, Loader2, Network, Radio, Search } from "lucide-react";
import React, { useState } from "react";
import { toast } from "sonner";

type NetworkTool = "ping" | "dns" | "ip" | "traceroute";

function page() {
  const [activeTab, setActiveTab] = useState<NetworkTool>("ping");
  const [input, setInput] = useState("");
  const [result, setResult] = useState<string | string[] | null>(null);
  const [loading, setLoading] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value);
  };

  const handleSubmit = async () => {
    if (!input) {
      toast.error("Please enter a valid input.");
      return;
    }

    setLoading(true);
    setResult(null);

    try {
      let response;

      switch (activeTab) {
        case "ping":
          response = await networkAPI.ping(input);
          setResult(response.data.result);
          break;
        case "dns":
          response = await networkAPI.dnsLookup(input);
          setResult(response.data.dns_records);
          break;
        case "ip":
          response = await networkAPI.ipLookup(input);
          setResult(response.data.ip);
          break;
        case "traceroute":
          response = await networkAPI.traceroute(input);
          setResult(response.data.result);
          break;
      }

      toast.success(`${getTabTitle()} completed successfully!`);
    } catch (error: any) {
      console.error("Network utility error:", error);
      toast.error(
        `Error: ${
          error.response?.data?.error || "Could not complete the operation."
        }`
      );
      setResult(
        error.response?.data?.error ||
          "Error: Could not complete the operation."
      );
    } finally {
      setLoading(false);
    }
  };

  const getPlaceholder = () => {
    switch (activeTab) {
      case "ping":
        return "Enter hostname or IP (e.g., google.com)";
      case "dns":
        return "Enter domain name (e.g., example.com)";
      case "ip":
        return "Enter domain name (e.g., github.com)";
      case "traceroute":
        return "Enter hostname or IP (e.g., microsoft.com)";
      default:
        return "Enter domain or IP address";
    }
  };

  const getIcon = () => {
    switch (activeTab) {
      case "ping":
        return <Activity className="h-5 w-5" />;
      case "dns":
        return <Search className="h-5 w-5" />;
      case "ip":
        return <Network className="h-5 w-5" />;
      case "traceroute":
        return <Radio className="h-5 w-5" />;
      default:
        return null;
    }
  };

  const getTabTitle = () => {
    switch (activeTab) {
      case "ping":
        return "Ping";
      case "dns":
        return "DNS Lookup";
      case "ip":
        return "IP Lookup";
      case "traceroute":
        return "Traceroute";
      default:
        return "";
    }
  };

  const getTabDescription = () => {
    switch (activeTab) {
      case "ping":
        return "Test connectivity to a host by sending ICMP echo requests";
      case "dns":
        return "Retrieve DNS records for a domain";
      case "ip":
        return "Lookup IP address for a domain name";
      case "traceroute":
        return "Trace the route packets take to a network host";
      default:
        return "";
    }
  };

  const formatResult = (result: string | string[] | null) => {
    if (!result) return null;

    if (Array.isArray(result)) {
      return (
        <ul className="list-disc pl-5 space-y-1">
          {result.map((item, index) => (
            <li key={index} className="text-foreground">
              {item}
            </li>
          ))}
        </ul>
      );
    }

    // Handle multiline text output (ping or traceroute)
    return (
      <pre className="bg-secondary/50 p-4 rounded-md text-sm overflow-x-auto whitespace-pre-wrap max-h-[400px] overflow-y-auto">
        {result}
      </pre>
    );
  };

  return (
    <Card className="border-0 bg-background/80 backdrop-blur-sm">
      <CardHeader>
        <TextGenerateEffect
          words="Network Utilities"
          className="text-2xl font-bold"
        />
        <CardDescription>
          Test connectivity and perform network diagnostics
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs
          defaultValue="ping"
          value={activeTab}
          onValueChange={(value) => setActiveTab(value as NetworkTool)}
        >
          <TabsList className="grid grid-cols-4 mb-6">
            <TabsTrigger value="ping">Ping</TabsTrigger>
            <TabsTrigger value="dns">DNS</TabsTrigger>
            <TabsTrigger value="ip">IP</TabsTrigger>
            <TabsTrigger value="traceroute">Traceroute</TabsTrigger>
          </TabsList>

          <div className="space-y-6">
            <div>
              <CardTitle className="flex items-center gap-2 mb-2">
                {getIcon()}
                {getTabTitle()}
              </CardTitle>
              <CardDescription className="mb-4">
                {getTabDescription()}
              </CardDescription>
            </div>

            <div className="flex items-center space-x-2">
              <Input
                type="text"
                placeholder={getPlaceholder()}
                value={input}
                onChange={handleInputChange}
                className="flex-1"
              />
              <Button
                onClick={handleSubmit}
                disabled={loading || !input}
                className="min-w-[100px]"
              >
                {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : "Run"}
              </Button>
            </div>

            {result !== null && (
              <div className="mt-6">
                <h3 className="text-lg font-medium mb-2">Result</h3>
                {formatResult(result)}
              </div>
            )}
          </div>
        </Tabs>
      </CardContent>
    </Card>
  );
}

export default page;
