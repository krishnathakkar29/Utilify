"use client";

import { DataTable } from "@/components/common/data-table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import type { ColumnDef } from "@tanstack/react-table";
import { format } from "date-fns";
import { MailIcon } from "lucide-react";
import * as React from "react";
import { SendEmailDialog } from "./send-email-dialog";

export type EmailHistory = {
  id: string;
  recipient: string;
  companyName: string;
  lastSentAt: Date;
  sendCount: number;
};

interface SendEmailDialogProps {
  isOpen: boolean;
  onClose: () => void;
  selectedEmails: Array<{
    recipient: string;
    emailId: string; // This still remains emailId since it's coming from the database
    companyName: string;
  }>;
}

export function EmailHistoryTable({ data }: { data: EmailHistory[] }) {
  const [rowSelection, setRowSelection] = React.useState({});
  const [filterValue, setFilterValue] = React.useState("");
  const [isDialogOpen, setIsDialogOpen] = React.useState(false);
  // Define the columns for our table
  const columns: ColumnDef<EmailHistory>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <div className="flex items-center justify-center">
          <Checkbox
            checked={
              table.getIsAllPageRowsSelected() ||
              (table.getIsSomePageRowsSelected() && "indeterminate")
            }
            onCheckedChange={(value) =>
              table.toggleAllPageRowsSelected(!!value)
            }
            aria-label="Select all"
          />
        </div>
      ),
      cell: ({ row }) => (
        <div className="flex items-center justify-center">
          <Checkbox
            checked={row.getIsSelected()}
            onCheckedChange={(value) => row.toggleSelected(!!value)}
            aria-label="Select row"
          />
        </div>
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: "recipient",
      header: "Email Address",
      cell: ({ row }) => (
        <div className="font-medium">{row.getValue("recipient")}</div>
      ),
    },
    {
      accessorKey: "companyName",
      header: "Company Name",
      cell: ({ row }) => <div>{row.getValue("companyName")}</div>,
    },
    {
      accessorKey: "lastSentAt",
      header: "Last Email Sent",
      cell: ({ row }) => {
        const date = row.getValue("lastSentAt") as Date;
        return <div>{format(date, "PPP")}</div>;
      },
      sortingFn: "datetime",
    },
    {
      accessorKey: "sendCount",
      header: "Send Count",
      cell: ({ row }) => {
        const count = row.getValue("sendCount") as number;
        return (
          <Badge variant="outline" className="px-2 py-1">
            {count} {count === 1 ? "time" : "times"}
          </Badge>
        );
      },
    },
  ];

  // Simplified filter logic
  const filteredData = React.useMemo(() => {
    if (!filterValue.trim()) return data;
    const searchTerm = filterValue.toLowerCase();
    return data.filter((item) =>
      Object.values(item).some(
        (value) =>
          typeof value === "string" && value.toLowerCase().includes(searchTerm)
      )
    );
  }, [data, filterValue]);

  const selectedEmails = React.useMemo(() => {
    return Object.keys(rowSelection)
      .map((key) => ({
        recipient: filteredData[parseInt(key)]?.recipient,
        emailId: filteredData[parseInt(key)]?.id,
        companyName: filteredData[parseInt(key)]?.companyName,
      }))
      .filter(
        (
          item
        ): item is {
          recipient: string;
          emailId: string;
          companyName: string;
        } => Boolean(item.recipient && item.emailId && item.companyName)
      );
  }, [rowSelection, filteredData]);

  const hasSelectedRows = selectedEmails.length > 0;

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between px-4">
        <div className="relative w-64">
          <Input
            placeholder="Search emails or companies..."
            value={filterValue}
            onChange={(e) => setFilterValue(e.target.value)}
            className="w-full"
          />
        </div>
      </div>

      <div className="rounded-lg border bg-card">
        <DataTable
          columns={columns}
          data={filteredData}
          rowSelection={rowSelection}
          onRowSelectionChange={setRowSelection}
        />
      </div>

      <div className="flex justify-end px-4">
        <Button
          onClick={() => setIsDialogOpen(true)}
          disabled={selectedEmails.length === 0}
          className="w-full sm:w-auto"
        >
          <MailIcon className="h-4 w-4 mr-2" />
          Send Email
          {selectedEmails.length > 0 ? ` (${selectedEmails.length})` : ""}
        </Button>
      </div>

      <SendEmailDialog
        isOpen={isDialogOpen}
        onClose={() => setIsDialogOpen(false)}
        selectedEmails={selectedEmails}
      />
    </div>
  );
}
