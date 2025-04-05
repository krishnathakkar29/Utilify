import React from "react";
import { getEmailHistory } from "../../../../actions/mail";
import { EmailHistoryTable } from "./email-history-table";

async function ViewHistory() {
  const emailHistoryData = await getEmailHistory();

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Email History</h1>
        <p className="text-muted-foreground">
          View and manage your sent emails history
        </p>
      </div>
      <EmailHistoryTable data={emailHistoryData} />
    </div>
  );
}

export default ViewHistory;
