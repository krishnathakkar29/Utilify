"use client";

import CommitLog from "@/components/pages/code/commit-log";
import { useProject } from "@/context/project-context";
import { ExternalLink, Github } from "lucide-react";
import Link from "next/link";

function page() {
  const { currentProject } = useProject();

  if (!currentProject) {
    return (
      <div className="text-white">
        No project selected.
        <br />
        Select a project from My Projects form the sidebar
      </div>
    );
  }

  return (
    <div className="text-white">
      <div className="flex items-center">
        <Github />
        <div className="flex items-center justify-center">
          This project is linked to{" "}
          <Link
            href={currentProject?.githubUrl ?? ""}
            className="inline-flex items-center hover:underlined text-white"
          >
            {currentProject?.name ?? ""}{" "}
            <ExternalLink className="ml-1 size-4" />
          </Link>
        </div>
      </div>

      {/* <div className="grid grid-cols-1">ask quertions card</div> */}

      <div className="mt-8">
        <CommitLog />
      </div>
    </div>
  );
}

export default page;
