"use client";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import axios from "axios";
import React, { useState } from "react";

function TalkDb() {
  const [dbUrl, setDbUrl] = useState("");
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [sqlResult, setSqlResult] = useState<null | {
    sql: string;
    rows_affected?: number;
    results?: any[];
    error?: string;
    note?: string;
  }>(null);

  const handleSubmit = async () => {
    if (!dbUrl || !query) return;
    setLoading(true);
    setSqlResult(null);

    try {
      const res = await axios.post(
        `https://reception-poultry-ec-booking.trycloudflare.com/generate-sql`,
        {
          db_url: dbUrl,
          query: query,
        }
      );

      setSqlResult(res.data);
    } catch (error: any) {
      setSqlResult({
        sql: "",
        error: error.response?.data?.error || "Something went wrong",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-start min-h-screen gap-4 p-6 bg-gray-900 text-white">
      <h1 className="text-3xl font-bold">Database Operations</h1>

      <Input
        className="w-[400px] text-white"
        placeholder="Enter your PostgreSQL DB URL"
        value={dbUrl}
        onChange={(e) => setDbUrl(e.target.value)}
      />
      <Input
        className="w-[400px] text-white"
        placeholder="Enter function/query in natural language"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      <Button
        onClick={handleSubmit}
        disabled={loading}
        className="bg-purple-700 text-white"
      >
        {loading ? "Generating..." : "Submit"}
      </Button>

      {sqlResult && (
        <Card className="w-full max-w-5xl mt-6 bg-gray-800 text-white overflow-hidden">
          <CardContent className="p-4 space-y-4">
            {sqlResult.sql && (
              <div>
                <strong>Generated SQL:</strong>
                <div className="overflow-x-auto max-w-full mt-1">
                  <pre className="bg-gray-700 p-2 rounded whitespace-pre-wrap break-words">
                    {sqlResult.sql}
                  </pre>
                </div>
              </div>
            )}

            {sqlResult.rows_affected !== undefined && (
              <div>
                <strong>Rows Affected:</strong> {sqlResult.rows_affected}
              </div>
            )}

            {sqlResult.error && (
              <div className="text-red-500">
                <strong>Error:</strong> {sqlResult.error}
              </div>
            )}

            {sqlResult.results && sqlResult.results.length > 0 && (
              <div>
                <strong>Results:</strong>
                <div className="overflow-auto max-h-[400px] mt-2 rounded border border-gray-700">
                  <table className="min-w-full text-sm text-white">
                    <thead className="bg-gray-700 text-left sticky top-0 z-10">
                      <tr>
                        {Object.keys(sqlResult.results[0]).map((key) => (
                          <th key={key} className="px-3 py-2 font-semibold">
                            {key}
                          </th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {sqlResult.results.map((row, i) => (
                        <tr
                          key={i}
                          className={
                            i % 2 === 0 ? "bg-gray-800" : "bg-gray-700"
                          }
                        >
                          {Object.values(row).map((val, j) => (
                            <td
                              key={j}
                              className="px-3 py-2 break-words max-w-[300px]"
                            >
                              {val?.toString()}
                            </td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {sqlResult.note && (
              <div className="text-yellow-400 italic">{sqlResult.note}</div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}

export default TalkDb;
