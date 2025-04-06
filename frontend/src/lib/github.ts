import axios from "axios";
import { Octokit } from "@octokit/core";
import prisma from "./db";
import { BACKEND_FLASK_URL } from "@/config/config";

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});

type response = {
  commitHash: string;
  commitMessage: string;
  commitAuthorName: string;
  commitAuthorAvatar: string;
  commitDate: string;
};

export const getCommitHashes = async (
  githubUrl: string
): Promise<response[]> => {
  const [owner, repoRaw] = githubUrl.split("/").slice(3, 5);
  const repo = repoRaw.replace(/\.git$/, "");

  const { data } = await octokit.request("GET /repos/{owner}/{repo}/commits", {
    owner,
    repo,
  });

  const sortedCommits = data.sort(
    (a: any, b: any) =>
      new Date(b.commit.author.date).getTime() -
      new Date(a.commit.author.date).getTime()
  ) as any[];

  return sortedCommits.slice(0, 2).map((commit: any) => ({
    commitHash: commit.sha as string,
    commitMessage: commit.commit.message ?? "",
    commitAuthorName: commit.commit?.author?.name ?? "",
    commitAuthorAvatar: commit.author?.avatar_url ?? "",
    commitDate: commit.commit?.author?.date ?? "",
  }));
};

export const pollRepo = async (githubUrl: string, projectId: string) => {
  try {
    const commitHases = await getCommitHashes(githubUrl);
    console.log("badsiofdasnfosd commit hashsdf");
    console.log(commitHases);
    const processedCommits = await prisma.commit.findMany({
      where: {
        projectId: projectId,
      },
    });

    const unprocessedCommits = commitHases.filter(
      (hash: any) =>
        !processedCommits.some(
          (commit) => commit.commitHash === hash.commitHash
        )
    );

    const summariesResponse = await Promise.allSettled(
      unprocessedCommits.map(async (hash) => {
        try {
          // Clean up the GitHub URL
          const baseUrl = githubUrl.replace(/\.git$/, "");
          const commitUrl = `${baseUrl}/commit/${hash.commitHash}`;

          const response = await fetch(
            `${BACKEND_FLASK_URL}/summarise-commit`,
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                github_url: commitUrl,
              }),
            }
          );

          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }

          const data = await response.json();
          return {
            success: true,
            summary: data.summary || "No summary available",
            commit: hash,
          };
        } catch (error) {
          console.error(`Error processing commit ${hash.commitHash}:`, error);
          return {
            success: false,
            summary: "Failed to analyze commit",
            commit: hash,
          };
        }
      })
    );

    // Create commits in database
    const commits = await prisma.commit.createMany({
      data: summariesResponse.map((result) => {
        const data =
          result.status === "fulfilled"
            ? result.value
            : {
                success: false,
                summary: "Failed to analyze commit",
                commit: unprocessedCommits[0],
              };

        return {
          projectId,
          commitHash: data.commit.commitHash,
          commitMessage: data.commit.commitMessage || "No message",
          commitAuthorName: data.commit.commitAuthorName || "Unknown",
          commitAuthorAvatar: data.commit.commitAuthorAvatar || "",
          commitDate: new Date(data.commit.commitDate),
          summary: data.summary,
        };
      }),
    });

    return commits;
  } catch (error) {
    console.error("Error in pollRepo:", error);
    throw error;
  }
};
