"use client";

import { useProject } from "@/context/project-context";
import { useQuery } from "@tanstack/react-query";
import { getCommitByProjectId } from "../../../../actions/project";
import Link from "next/link";
import { ExternalLink } from "lucide-react";
import { cn } from "@/lib/utils";

function CommitLog() {
  const { currentProject } = useProject();
  const { data: commits, isLoading } = useQuery({
    queryKey: ["commits", currentProject?.id],
    queryFn: async () => {
      const response = await getCommitByProjectId(currentProject?.id as string);
      console.log("osndfnason");
      console.log(response);
      return response;
    },
    refetchInterval: 1000 * 60 * 4, // 5 minutes
  });

  console.log("commits", commits);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-full">
        <p className="text-white">Loading...</p>
      </div>
    );
  }
  return (
    <>
      <ul role="list" className="space-y-6 ">
        {commits?.map((commit: any, commitIdx: any) => (
          <li key={commit.id} className="relative flex gap-x-4">
            <div
              className={cn(
                commitIdx === commits?.length - 1 ? "h-6" : "-bottom-6",
                "absolute left-0 top-0 flex w-6 justify-center"
              )}
            >
              <div className="w-px translate-x-1 bg-gray-200" />
            </div>
            <>
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src={commit.commitAuthorAvatar}
                alt=""
                className="relative mt-3 h-8 w-8 flex-none rounded-full bg-gray-50"
              />
              <div className="flex-auto rounded-md bg-white p-3 ring-1 ring-inset ring-gray-200">
                <div className="flex justify-between gap-x-4">
                  <Link
                    target="_blank"
                    className="py-0.5 text-xs leading-5 text-gray-500"
                    href={`https://github.com/krishnathakkar29/scheduler.git/commits/${commit.commitHash}`}
                  >
                    <span className="font-medium text-gray-900">
                      {commit.commitAuthorName}
                    </span>{" "}
                    <span className="inline-flex items-center">
                      committed
                      <ExternalLink className="ml-1 h-4 w-4" />
                    </span>
                  </Link>
                  <time
                    dateTime={commit.commitDate.toString()}
                    className="flex-none py-0.5 text-xs leading-5 text-gray-500"
                  >
                    {new Date(commit.commitDate).toLocaleString()}
                  </time>
                </div>
                <span className="font-semibold text-black">
                  {commit.commitMessage}
                </span>
                <pre className="mt-2 whitespace-pre-wrap text-sm leading-6 text-gray-500">
                  {commit.summary}
                </pre>
              </div>
            </>
          </li>
        ))}
      </ul>
    </>
  );
}

export default CommitLog;
